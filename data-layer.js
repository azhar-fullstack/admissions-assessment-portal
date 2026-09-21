/**
 * Admissions Portal — Supabase auth + store (production).
 */
(function (global) {
  function uid() {
    return global.crypto && crypto.randomUUID
      ? crypto.randomUUID()
      : "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, (c) => {
          const r = (Math.random() * 16) | 0;
          return (c === "x" ? r : (r & 0x3) | 0x8).toString(16);
        });
  }

  function cfg() {
    return global.PORTAL_CONFIG || {};
  }

  function requireConfig() {
    const c = cfg();
    if (!c.SUPABASE_URL || !c.SUPABASE_ANON_KEY) {
      throw new Error("Portal is not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY in config.js.");
    }
    if (!global.supabase || !global.supabase.createClient) {
      throw new Error("Supabase client library failed to load. Check your network connection.");
    }
  }

  let sbClient = null;

  function getClient() {
    requireConfig();
    if (sbClient) return sbClient;
    const c = cfg();
    sbClient = global.supabase.createClient(c.SUPABASE_URL, c.SUPABASE_ANON_KEY, {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: false,
      },
    });
    return sbClient;
  }

  async function enrichUser(sessionUser) {
    if (!sessionUser) return null;
    const sb = getClient();
    let full_name = sessionUser.user_metadata?.full_name || sessionUser.email || "Staff";
    let role = "staff";
    const { data } = await sb.from("staff_profiles").select("full_name, role, is_active").eq("id", sessionUser.id).maybeSingle();
    if (data) {
      if (data.is_active === false) {
        await sb.auth.signOut();
        return null;
      }
      full_name = data.full_name || full_name;
      role = data.role || role;
    }
    return {
      id: sessionUser.id,
      email: sessionUser.email,
      full_name,
      role,
    };
  }

  function attachStudentFields(assessment, student) {
    return {
      ...assessment,
      student_name: student?.full_name || assessment.student_name || "Student",
      dob: student?.dob || assessment.dob || "",
      age: student?.age || assessment.age || "",
      guardian: student?.guardian || assessment.guardian || "",
      previous_school: student?.previous_school || assessment.previous_school || "",
      home_language: student?.home_language || assessment.home_language || "",
    };
  }

  const SupabaseAuth = {
    mode: "supabase",
    async getSession() {
      const sb = getClient();
      const { data, error } = await sb.auth.getSession();
      if (error || !data.session?.user) return null;
      const user = await enrichUser(data.session.user);
      if (!user) return null;
      return { user };
    },
    async signInWithPassword({ email, password }) {
      const sb = getClient();
      const { data, error } = await sb.auth.signInWithPassword({
        email: String(email || "").trim(),
        password: String(password || ""),
      });
      if (error) {
        return { data: { user: null, session: null }, error: new Error(error.message || "Sign in failed.") };
      }
      const user = await enrichUser(data.user);
      if (!user) {
        return {
          data: { user: null, session: null },
          error: new Error("Your staff account is inactive or not provisioned. Contact an administrator."),
        };
      }
      return { data: { user, session: { user } }, error: null };
    },
    async signOut() {
      const sb = getClient();
      const { error } = await sb.auth.signOut();
      return { error: error ? new Error(error.message) : null };
    },
    async getSupabaseClient() {
      return getClient();
    },
  };

  const SupabaseStore = {
    mode: "supabase",

    async listStudents() {
      const sb = getClient();
      const { data, error } = await sb.from("students").select("*").order("full_name", { ascending: true });
      if (error) throw new Error(error.message);
      return data || [];
    },

    async getStudent(id) {
      const sb = getClient();
      const { data, error } = await sb.from("students").select("*").eq("id", id).maybeSingle();
      if (error) throw new Error(error.message);
      return data || null;
    },

    async upsertStudent(student) {
      const sb = getClient();
      const now = new Date().toISOString();
      const existing = student.id ? await this.getStudent(student.id) : null;
      if (existing) {
        const { data, error } = await sb
          .from("students")
          .update({
            full_name: student.full_name,
            dob: student.dob || null,
            age: student.age || null,
            guardian: student.guardian || null,
            previous_school: student.previous_school || null,
            home_language: student.home_language || null,
            updated_at: now,
          })
          .eq("id", existing.id)
          .select("*")
          .single();
        if (error) throw new Error(error.message);
        return data;
      }
      const row = {
        id: student.id || uid(),
        full_name: student.full_name,
        dob: student.dob || null,
        age: student.age || null,
        guardian: student.guardian || null,
        previous_school: student.previous_school || null,
        home_language: student.home_language || null,
        created_at: now,
        updated_at: now,
        created_by: student.created_by || null,
      };
      const { data, error } = await sb.from("students").insert(row).select("*").single();
      if (error) throw new Error(error.message);
      return data;
    },

    async findDuplicateStudent({ full_name, dob }) {
      const name = String(full_name || "")
        .trim()
        .toLowerCase();
      const all = await this.listStudents();
      return (
        all.find(
          (s) =>
            String(s.full_name).toLowerCase() === name && ((dob && s.dob === dob) || (!dob && !s.dob))
        ) || null
      );
    },

    async listAssessments() {
      const sb = getClient();
      const { data, error } = await sb
        .from("assessments")
        .select("*, students(*)")
        .order("updated_at", { ascending: false });
      if (error) throw new Error(error.message);
      return (data || []).map((a) => {
        const student = a.students || null;
        const { students, ...rest } = a;
        return attachStudentFields(rest, student);
      });
    },

    async getAssessment(id) {
      const sb = getClient();
      const { data, error } = await sb.from("assessments").select("*, students(*)").eq("id", id).maybeSingle();
      if (error) throw new Error(error.message);
      if (!data) return null;
      const student = data.students || null;
      const { students, ...rest } = data;
      return attachStudentFields(rest, student);
    },

    async findInProgress({ student_id, class_level, admission_year }) {
      const sb = getClient();
      const { data, error } = await sb
        .from("assessments")
        .select("*, students(*)")
        .eq("student_id", student_id)
        .eq("class_level", Number(class_level))
        .eq("admission_year", String(admission_year || ""))
        .eq("status", "in_progress")
        .order("updated_at", { ascending: false })
        .limit(1)
        .maybeSingle();
      if (error) throw new Error(error.message);
      if (!data) return null;
      const student = data.students || null;
      const { students, ...rest } = data;
      return attachStudentFields(rest, student);
    },

    async upsertAssessment(assessment) {
      const sb = getClient();
      const now = new Date().toISOString();
      const existing = assessment.id ? await this.getAssessment(assessment.id) : null;
      const fields = {
        student_id: assessment.student_id,
        admission_year: assessment.admission_year || "",
        class_level: Number(assessment.class_level),
        assessment_date: assessment.assessment_date,
        status: assessment.status || "in_progress",
        responses: assessment.responses || {},
        teacher_narrative: assessment.teacher_narrative || "",
        score_summary: assessment.score_summary || {},
        recommendation: assessment.recommendation || "",
        updated_at: now,
        updated_by: assessment.updated_by || null,
      };
      if (existing) {
        const { error } = await sb.from("assessments").update(fields).eq("id", existing.id);
        if (error) throw new Error(error.message);
        return this.getAssessment(existing.id);
      }
      const id = assessment.id || uid();
      const { error } = await sb.from("assessments").insert({
        id,
        ...fields,
        created_at: assessment.created_at || now,
        created_by: assessment.created_by || null,
      });
      if (error) throw new Error(error.message);
      return this.getAssessment(id);
    },

    async stats() {
      const assessments = await this.listAssessments();
      const students = await this.listStudents();
      return {
        students: students.length,
        assessments: assessments.length,
        completed: assessments.filter((a) => a.status === "completed").length,
        in_progress: assessments.filter((a) => a.status !== "completed").length,
      };
    },
  };

  try {
    requireConfig();
  } catch (err) {
    console.error(err.message);
  }

  global.PortalLayer = {
    PHASE: "supabase",
    auth: SupabaseAuth,
    store: SupabaseStore,
    uid,
  };
})(window);
