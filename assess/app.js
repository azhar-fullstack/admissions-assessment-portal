/**
 * Admissions Assessment Portal — Primary 1–6
 * Supabase auth + central store via PortalLayer.
 * Scoring rules & question-bank content are preserved from the client package.
 */
let BANK = {};
let currentUser = null;
let currentAssessment = null;
let selectedStudent = null;
let pageIndex = 0;
let autosaveTimer = null;
let dirty = false;
let saving = false;
let readOnly = false;

const auth = () => window.PortalLayer.auth;
const store = () => window.PortalLayer.store;
const $ = (s) => document.querySelector(s);
const $$ = (s) => [...document.querySelectorAll(s)];
const today = () => new Date().toISOString().slice(0, 10);
const esc = (s) =>
  String(s ?? "").replace(/[&<>"']/g, (m) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[m]));

function defaultAdmissionYear(d = new Date()) {
  const y = d.getFullYear();
  const m = d.getMonth();
  return m >= 7 ? `${y}/${y + 1}` : `${y - 1}/${y}`;
}

function notify(el, msg, isError = true) {
  if (!el) return;
  el.textContent = msg || "";
  el.classList.toggle("ok", !isError && !!msg);
}

async function init() {
  try {
    BANK = await (await fetch("question-bank.json")).json();
  } catch (err) {
    console.error(err);
    notify($("#loginMsg"), "Could not load assessment content. Keep all portal files in the same folder.");
    return;
  }

  $("#assessmentDate").value = today();
  $("#admissionYear").value = defaultAdmissionYear();
  const years = [];
  const base = new Date().getFullYear();
  for (let i = -1; i <= 2; i++) years.push(`${base + i}/${base + i + 1}`);
  $("#yearSuggestions").innerHTML = years.map((y) => `<option value="${esc(y)}">`).join("");

  $("#modeBadge").textContent = "Staff portal";

  bind();

  const session = await auth().getSession();
  if (session?.user) {
    currentUser = session.user;
    openApp();
  }

  window.addEventListener("beforeunload", (e) => {
    if (dirty && currentAssessment && currentAssessment.status !== "completed") {
      e.preventDefault();
      e.returnValue = "";
    }
  });
}

function bind() {
  $("#loginBtn").onclick = login;
  $("#logoutBtn").onclick = logout;
  $$(".nav").forEach((b) => (b.onclick = () => switchView(b.dataset.view)));
  $$("[data-jump]").forEach((b) => (b.onclick = () => switchView(b.dataset.jump)));
  $$("[data-student-tab]").forEach((b) => (b.onclick = () => setStudentTab(b.dataset.studentTab)));
  $("#beginBtn").onclick = beginAssessment;
  $("#saveBtn").onclick = () => saveAssessment(false);
  $("#finishBtn").onclick = () => completeAndReport();
  $("#prevPage").onclick = () => showAssessmentPage(pageIndex - 1);
  $("#nextPage").onclick = () => {
    if (pageIndex < 4) showAssessmentPage(pageIndex + 1);
    else completeAndReport();
  };
  $("#recordSearch").oninput = () => loadRecords();
  $("#filterStatus").onchange = () => loadRecords();
  $("#filterClass").onchange = () => loadRecords();
  $("#studentSearchInput").oninput = () => searchStudents();
  $("#closeReport").onclick = closeReport;
  $("#closeReport2").onclick = closeReport;
  $("#printReport").onclick = () => window.print();
  $("#emailReport") && ($("#emailReport").onclick = emailParentReport);
  const im = $("#interviewModeToggle");
  if (im) {
    im.checked = localStorage.getItem("portal_interview_mode") === "1";
    document.body.classList.toggle("interview-mode", im.checked);
    im.onchange = () => {
      localStorage.setItem("portal_interview_mode", im.checked ? "1" : "0");
      document.body.classList.toggle("interview-mode", im.checked);
      if (im.checked) startInterviewAutosave();
      else stopInterviewAutosave();
    };
    if (im.checked) startInterviewAutosave();
  }
  $("#openYearBtn") && ($("#openYearBtn").onclick = openAcademicYear);
  $("#archiveYearBtn") && ($("#archiveYearBtn").onclick = archiveAcademicYear);
  loadAcademicYears();
  $("#email").addEventListener("keydown", (e) => e.key === "Enter" && login());
  $("#password").addEventListener("keydown", (e) => e.key === "Enter" && login());
}

function closeReport() {
  $("#reportModal").classList.add("hidden");
}

async function login() {
  notify($("#loginMsg"), "");
  const email = $("#email").value.trim();
  const password = $("#password").value;
  if (!email || !password) {
    notify($("#loginMsg"), "Enter your email and password.");
    return;
  }
  $("#loginBtn").disabled = true;
  const { data, error } = await auth().signInWithPassword({ email, password });
  $("#loginBtn").disabled = false;
  if (error) {
    notify($("#loginMsg"), error.message || "Sign in failed.");
    return;
  }
  currentUser = data.user;
  openApp();
}

async function logout() {
  if (dirty && currentAssessment && currentAssessment.status !== "completed") {
    if (!confirm("You have unsaved changes. Sign out anyway?")) return;
  }
  dirty = false;
  await auth().signOut();
  location.reload();
}

function openApp() {
  $("#loginView").classList.add("hidden");
  $("#appView").classList.remove("hidden");
  $("#logoutBtn").classList.remove("hidden");
  $("#staffLabel").classList.remove("hidden");
  $("#staffLabel").textContent = currentUser?.full_name || currentUser?.email || "Staff";
  $("#modeBadge").textContent = "Staff portal";
  refreshDashboard();
  loadRecords();
  searchStudents();
}

function switchView(id) {
  if (id !== "new" && dirty && currentAssessment && currentAssessment.status !== "completed") {
    if (!confirm("You have unsaved assessment changes. Leave without saving?")) return;
  }
  $$(".view").forEach((v) => v.classList.toggle("active", v.id === id));
  $$(".nav").forEach((n) => n.classList.toggle("active", n.dataset.view === id));
  if (id === "dashboard") refreshDashboard();
  if (id === "records") loadRecords();
  if (id === "new") {
    $("#newStart").classList.remove("hidden");
    if (!currentAssessment || currentAssessment.status === "completed" || readOnly) {
      if (readOnly || (currentAssessment && currentAssessment.status === "completed")) {
        $("#assessmentWorkspace").classList.add("hidden");
        currentAssessment = null;
        readOnly = false;
      }
    }
  }
}

function setStudentTab(tab) {
  $$("[data-student-tab]").forEach((b) => b.classList.toggle("active", b.dataset.studentTab === tab));
  $("#studentSearchPane").classList.toggle("hidden", tab !== "search");
  $("#studentCreatePane").classList.toggle("hidden", tab !== "create");
  if (tab === "create") {
    selectedStudent = null;
    $("#selectedStudentCard").classList.add("hidden");
    $("#studentHistory").classList.add("hidden");
  }
  notify($("#newMsg"), "");
}

/* -------------------- Students -------------------- */

async function searchStudents() {
  const q = ($("#studentSearchInput")?.value || "").trim().toLowerCase();
  const students = await store().listStudents();
  const filtered = !q
    ? students.slice(0, 30)
    : students
        .filter((s) =>
          [s.full_name, s.guardian, s.previous_school, s.home_language]
            .filter(Boolean)
            .join(" ")
            .toLowerCase()
            .includes(q)
        )
        .slice(0, 40);
  const box = $("#studentSearchResults");
  if (!filtered.length) {
    box.innerHTML = `<p class="muted">${q ? "No matching students." : "No students yet. Use Create student to add one."}</p>`;
    return;
  }
  box.innerHTML = filtered
    .map(
      (s) => `<button type="button" class="search-item" data-sid="${esc(s.id)}">
      <strong>${esc(s.full_name)}</strong>
      <span class="muted">${esc([s.dob ? "DOB " + s.dob : "", s.guardian || ""].filter(Boolean).join(" • "))}</span>
    </button>`
    )
    .join("");
  box.querySelectorAll("[data-sid]").forEach((btn) => {
    btn.onclick = () => selectStudentById(btn.dataset.sid);
  });
}

async function selectStudentById(id) {
  const s = await store().getStudent(id);
  if (!s) {
    notify($("#newMsg"), "Student record not found.");
    return;
  }
  selectedStudent = s;
  $("#selectedStudentCard").classList.remove("hidden");
  $("#selectedStudentCard").innerHTML = `<strong>Selected:</strong> ${esc(s.full_name)}
    <button type="button" class="smallbtn" id="clearSelectedStudent">Clear</button>
    <div class="muted small">${esc(
      [s.dob ? "DOB " + s.dob : "", s.age ? "Age " + s.age : "", s.guardian || "", s.previous_school || ""]
        .filter(Boolean)
        .join(" • ")
    )}</div>`;
  $("#clearSelectedStudent").onclick = () => {
    selectedStudent = null;
    $("#selectedStudentCard").classList.add("hidden");
    $("#studentHistory").classList.add("hidden");
  };
  await showStudentHistory(s.id);
  notify($("#newMsg"), "");
}

async function showStudentHistory(studentId) {
  const rec = (await store().listAssessments()).filter((a) => a.student_id === studentId);
  const box = $("#studentHistory");
  if (!rec.length) {
    box.classList.add("hidden");
    return;
  }
  box.classList.remove("hidden");
  box.innerHTML = `<h3>Assessment history</h3>
    <ul class="history-list">${rec
      .map((a) => {
        const s = a.score_summary?.total ?? scores(a).total;
        return `<li>
          <span>Primary ${a.class_level} • ${esc(a.admission_year || "—")} • ${esc(a.assessment_date || "")} •
            <span class="status status-${esc(a.status)}">${esc(a.status)}</span> • ${s}/120</span>
          <span class="table-actions">
            ${a.status !== "completed" ? `<button type="button" class="smallbtn" data-resume="${a.id}">Continue</button>` : ""}
            <button type="button" class="smallbtn" data-view="${a.id}">View report</button>
          </span>
        </li>`;
      })
      .join("")}</ul>`;
  box.querySelectorAll("[data-resume]").forEach((b) => (b.onclick = () => resumeRecord(b.dataset.resume)));
  box.querySelectorAll("[data-view]").forEach((b) => (b.onclick = () => openRecord(b.dataset.view)));
}

function readNewStudentForm() {
  return {
    full_name: $("#studentName").value.trim(),
    dob: $("#studentDob").value || null,
    age: $("#studentAge").value.trim() || null,
    guardian: $("#guardian").value.trim() || null,
    previous_school: $("#previousSchool").value.trim() || null,
    home_language: $("#homeLanguage").value.trim() || null,
  };
}

async function beginAssessment() {
  notify($("#newMsg"), "");
  const admissionYear = $("#admissionYear").value.trim();
  const classLevel = $("#classLevel").value;
  const assessmentDate = $("#assessmentDate").value || today();
  if (!admissionYear) {
    notify($("#newMsg"), "Enter the admission year.");
    return;
  }
  if (!BANK[classLevel]) {
    notify($("#newMsg"), "Assessment content for this class is missing.");
    return;
  }

  let student = selectedStudent;
  const createPaneOpen = !$("#studentCreatePane").classList.contains("hidden");

  if (!student || createPaneOpen) {
    const form = readNewStudentForm();
    if (!form.full_name) {
      notify($("#newMsg"), "Enter the student name, or select an existing student.");
      return;
    }
    const dup = await store().findDuplicateStudent(form);
    if (dup && !selectedStudent) {
      const useExisting = confirm(
        `A student named "${dup.full_name}" already exists${dup.dob ? " (DOB " + dup.dob + ")" : ""}. Use the existing record instead of creating a duplicate?`
      );
      if (useExisting) {
        await selectStudentById(dup.id);
        student = selectedStudent;
      } else {
        student = await store().upsertStudent({ ...form, id: window.PortalLayer.uid(), created_by: currentUser?.id });
      }
    } else if (!selectedStudent) {
      student = await store().upsertStudent({ ...form, id: window.PortalLayer.uid(), created_by: currentUser?.id });
    } else {
      student = selectedStudent;
    }
  }

  if (!student) {
    notify($("#newMsg"), "Could not create or select student.");
    return;
  }

  // Continue unfinished instead of duplicating
  const existing = await store().findInProgress({
    student_id: student.id,
    class_level: classLevel,
    admission_year: admissionYear,
  });
  if (existing) {
    const cont = confirm(
      `An unfinished Primary ${classLevel} assessment for ${student.full_name} (${admissionYear}) already exists. Continue that assessment instead of starting a new one?`
    );
    if (cont) {
      await resumeRecord(existing.id);
      return;
    }
  }

  const bank = BANK[classLevel];
  currentAssessment = {
    id: window.PortalLayer.uid(),
    student_id: student.id,
    student_name: student.full_name,
    dob: student.dob || "",
    age: student.age || "",
    guardian: student.guardian || "",
    previous_school: student.previous_school || "",
    home_language: student.home_language || "",
    admission_year: admissionYear,
    class_level: Number(classLevel),
    assessment_date: assessmentDate,
    status: "in_progress",
    responses: {},
    teacher_narrative: "",
    recommendation: "",
    created_at: new Date().toISOString(),
    created_by: currentUser?.id || null,
  };

  readOnly = false;
  dirty = true;
  openAssessmentWorkspace(bank, student.full_name);
  await saveAssessment(false, true);
}

function openAssessmentWorkspace(bank, studentName) {
  $("#newStart").classList.add("hidden");
  $("#assessmentWorkspace").classList.remove("hidden");
  $("#assessmentTitle").textContent = `${bank.label} Admission Assessment — ${studentName}`;
  $("#assessmentBasis").textContent = bank.basis;
  $("#assessmentMeta").textContent = `Admission year: ${currentAssessment.admission_year} • Class applied for: Primary ${currentAssessment.class_level} • ${currentAssessment.assessment_date}`;
  $("#assessLockBanner").classList.toggle("hidden", !readOnly);
  $("#saveBtn").disabled = readOnly;
  $("#finishBtn").disabled = readOnly;
  renderAssessment(bank);
  showAssessmentPage(0);
  scheduleAutosave();
}

/* -------------------- Scoring (unchanged rules) -------------------- */

function maxPtsForIndex(i) {
  return i < 10 ? 1 : 2;
}

function isRubricKey(key) {
  const k = String(key || "").toLowerCase();
  if (!k) return true;
  if (k.length > 42) return true;
  return /e\.g\.|meaningful|sentence|recognizable|legible|organized|paragraph|connected sentences|ask |both |protection|explain|clarify|compare|recalculate|avoid|share\/|take turns|use another|weak\/|labour|responsible|reduces flooding|ask for help|light\/dark|or reasonable|etc\.|community leaders|final primary/.test(
    k
  );
}

function normalizeAnswer(s) {
  return String(s ?? "")
    .trim()
    .toLowerCase()
    .replace(/,/g, "")
    .replace(/\s+/g, " ")
    .replace(/[’']/g, "'");
}

function answersMatch(response, key) {
  const r = normalizeAnswer(response);
  const k = normalizeAnswer(key);
  if (!r || !k) return false;
  if (r === k) return true;
  const parts = k
    .split(/[;/]/)
    .map((p) => p.trim())
    .filter(Boolean);
  if (parts.length > 1 && parts.some((p) => p === r || r.includes(p) || p.includes(r))) return true;
  return false;
}

/** Auto-score Math/English discrete items only. Keys never shown in UI. */
function suggestObjectiveScore(section, index, response, key) {
  if (!["math", "english"].includes(section)) return null;
  if (isRubricKey(key)) return null;
  if (!String(response || "").trim()) return null;
  const max = maxPtsForIndex(index);
  return answersMatch(response, key) ? max : 0;
}

function renderAssessment(bank) {
  const nav = $("#assessmentNav");
  const pages = $("#assessmentPages");
  nav.innerHTML = "";
  pages.innerHTML = "";
  const specs = [
    ["math", "Mathematics", bank.math],
    ["english", "English & Literacy", bank.english],
    ["reasoning", "Reasoning", bank.reasoning],
    ["motor", "Motor/Writing", bank.motor],
    ["observation", "Teacher Observation", bank.observation],
  ];

  specs.forEach((sp, idx) => {
    const [key, title, items] = sp;
    const nb = document.createElement("button");
    nb.type = "button";
    nb.textContent = `${idx + 1}. ${title}`;
    nb.onclick = () => showAssessmentPage(idx);
    nav.appendChild(nb);

    const sec = document.createElement("section");
    sec.className = "assessment-page";
    sec.dataset.index = idx;
    const markNote =
      key === "observation"
        ? "Contextual profile — reported separately from the 120 marks."
        : key === "motor"
          ? "Teacher-scored Motor/Writing tasks (domain /30)."
          : key === "reasoning"
            ? "Teacher-scored Reasoning section. Enter the response and select the score."
            : "Enter the student response. Objective items are auto-scored; you may override any score.";
    sec.innerHTML = `<div class="panel"><h2>${title}${key === "observation" ? "" : " — 30 Marks"}</h2>
      <p class="muted">${markNote}</p>
      <div id="box-${key}"></div>
      ${
        key === "observation"
          ? '<label>Teacher overall observation<textarea id="teacherNarrative" rows="6" placeholder="Overall observation notes"></textarea></label>'
          : ""
      }
    </div>`;
    pages.appendChild(sec);
    const box = sec.querySelector(`#box-${key}`);
    const dis = readOnly ? "disabled" : "";

    if (["math", "english", "reasoning"].includes(key)) {
      items.forEach((q, i) => {
        const prompt = Array.isArray(q) ? q[0] : q;
        const answerKey = Array.isArray(q) ? q[1] : "";
        const max = maxPtsForIndex(i);
        const opts = Array.from({ length: max + 1 }, (_, x) => `<option value="${x}">${x}</option>`).join("");
        const autoHint =
          key !== "reasoning" && !isRubricKey(answerKey)
            ? `<span class="score-hint" data-hint="${key}_${i}"></span>`
            : `<span class="score-hint manual">Teacher scored</span>`;
        box.insertAdjacentHTML(
          "beforeend",
          `<div class="q" data-section="${key}" data-qi="${i}">
            <div class="q-title">${i + 1}. ${esc(prompt)}</div>
            <div class="q-grid">
              <label>Student response<input data-response="${key}_resp_${i}" data-section="${key}" data-qi="${i}" autocomplete="off" ${dis}></label>
              <label>Score (0–${max})
                <select data-score="${key}_${i}" data-section="${key}" data-qi="${i}" data-manual-override="0" ${dis}>
                  <option value="">Select</option>${opts}
                </select>
              </label>
            </div>
            ${autoHint}
          </div>`
        );
      });
    } else if (key === "motor") {
      items.forEach((q, i) => {
        box.insertAdjacentHTML(
          "beforeend",
          `<div class="q">
            <div class="q-title">${i + 1}. ${esc(q)}</div>
            <div class="q-grid">
              <label>Observation<input data-response="motor_note_${i}" autocomplete="off" ${dis}></label>
              <label>Score
                <select data-score="motor_${i}" ${dis}>
                  <option value="">Select</option>
                  <option value="2">2 — Independent</option>
                  <option value="1">1 — Developing</option>
                  <option value="0">0 — Difficulty</option>
                </select>
              </label>
            </div>
          </div>`
        );
      });
    } else {
      items.forEach((q, i) => {
        box.insertAdjacentHTML(
          "beforeend",
          `<div class="q">
            <div class="q-grid">
              <div class="q-title">${i + 1}. ${esc(q)}</div>
              <select data-score="obs_${i}" ${dis}>
                <option value="">Not rated</option>
                <option value="3">3 — Consistently</option>
                <option value="2">2 — Usually</option>
                <option value="1">1 — Sometimes</option>
                <option value="0">0 — Rarely / concern</option>
              </select>
            </div>
          </div>`
        );
      });
    }
  });

  if (!readOnly) {
    pages.oninput = onAssessmentInput;
    pages.onchange = onAssessmentInput;
  } else {
    pages.oninput = null;
    pages.onchange = null;
  }
}

function onAssessmentInput(e) {
  if (readOnly) return;
  capture();
  dirty = true;
  const t = e.target;
  if (t && t.matches("[data-response]") && ["math", "english"].includes(t.dataset.section)) {
    maybeAutoScore(t.dataset.section, Number(t.dataset.qi));
  }
  if (t && t.matches("[data-score]") && t.dataset.manualOverride !== undefined) {
    t.dataset.manualOverride = "1";
  }
  scheduleAutosave();
  updateProgress();
}

function maybeAutoScore(section, index) {
  const bank = BANK[String(currentAssessment.class_level)];
  if (!bank) return;
  const item = bank[section][index];
  if (!Array.isArray(item)) return;
  const key = item[1];
  const respEl = $(`[data-response="${section}_resp_${index}"]`);
  const scoreEl = $(`[data-score="${section}_${index}"]`);
  const hint = $(`[data-hint="${section}_${index}"]`);
  if (!respEl || !scoreEl) return;
  if (scoreEl.dataset.manualOverride === "1" && scoreEl.value !== "") {
    if (hint) hint.textContent = "Teacher override";
    return;
  }
  const suggested = suggestObjectiveScore(section, index, respEl.value, key);
  if (suggested === null) {
    if (hint) hint.textContent = isRubricKey(key) ? "Teacher scored" : "";
    return;
  }
  scoreEl.value = String(suggested);
  scoreEl.dataset.manualOverride = "0";
  if (hint) hint.textContent = suggested > 0 ? "Auto-scored ✓" : "Auto-scored (no match — adjust if needed)";
  capture();
}

function capture() {
  if (!currentAssessment) return;
  $$("[data-response]").forEach((x) => {
    currentAssessment.responses[x.dataset.response] = x.value;
  });
  $$("[data-score]").forEach((x) => {
    currentAssessment.responses["score_" + x.dataset.score] = x.value;
  });
  const tn = $("#teacherNarrative");
  if (tn) currentAssessment.teacher_narrative = tn.value;
}

function showAssessmentPage(i) {
  pageIndex = Math.max(0, Math.min(4, i));
  $$(".assessment-page").forEach((p, j) => p.classList.toggle("active", j === pageIndex));
  $$("#assessmentNav button").forEach((b, j) => b.classList.toggle("active", j === pageIndex));
  $("#prevPage").disabled = pageIndex === 0;
  $("#nextPage").textContent = pageIndex === 4 ? (readOnly ? "View Report" : "Complete & Report") : "Next";
  updateProgress();
}

function updateProgress() {
  const fill = $("#progressFill");
  const text = $("#progressText");
  if (fill) fill.style.width = `${((pageIndex + 1) / 5) * 100}%`;
  if (text) text.textContent = `Section ${pageIndex + 1} of 5`;
}

function scores(a) {
  const r = a.responses || {};
  const sum = (p, n) =>
    Array.from({ length: n }, (_, i) => Number(r[`score_${p}_${i}`] || 0)).reduce((x, y) => x + y, 0);
  const m = sum("math", 20);
  const e = sum("english", 20);
  const rea = sum("reasoning", 20);
  const mo = sum("motor", 15);
  const total = m + e + rea + mo;
  const obs = [];
  Object.keys(r)
    .filter((k) => k.startsWith("score_obs_"))
    .forEach((k) => {
      if (r[k] !== "") obs.push(Number(r[k]));
    });
  return {
    m,
    e,
    rea,
    mo,
    total,
    obsavg: obs.length ? (obs.reduce((x, y) => x + y, 0) / obs.length).toFixed(1) : "Not rated",
  };
}

function readiness(total, cls) {
  if (total >= 100) return `Strong readiness for Class ${cls}`;
  if (total >= 80) return `Ready for Class ${cls} with normal classroom support`;
  if (total >= 60) return `Developing readiness — targeted support recommended`;
  return `Further individual review recommended before Class ${cls} placement`;
}

function scheduleAutosave() {
  clearTimeout(autosaveTimer);
  if (readOnly) return;
  autosaveTimer = setTimeout(() => {
    if (currentAssessment && currentAssessment.status !== "completed" && dirty) {
      saveAssessment(false, true);
    }
  }, 5000);
}

async function saveAssessment(markComplete = false, silent = false) {
  capture();
  if (!currentAssessment || saving) return false;
  if (readOnly && !markComplete) {
    if (!silent) notify($("#saveStatus"), "Read-only");
    return false;
  }
  saving = true;
  $("#saveStatus").textContent = "Saving…";

  if (markComplete) currentAssessment.status = "completed";
  currentAssessment.updated_at = new Date().toISOString();
  currentAssessment.updated_by = currentUser?.id || null;
  currentAssessment.score_summary = scores(currentAssessment);
  currentAssessment.recommendation = readiness(currentAssessment.score_summary.total, currentAssessment.class_level);

  try {
    await store().upsertStudent({
      id: currentAssessment.student_id,
      full_name: currentAssessment.student_name,
      dob: currentAssessment.dob || null,
      age: currentAssessment.age || null,
      guardian: currentAssessment.guardian || null,
      previous_school: currentAssessment.previous_school || null,
      home_language: currentAssessment.home_language || null,
      created_by: currentUser?.id || null,
    });
    await store().upsertAssessment(currentAssessment);
    dirty = false;
    $("#saveStatus").textContent = markComplete ? "Completed" : "Saved " + new Date().toLocaleTimeString();
    refreshDashboard();
    loadRecords();
    saving = false;
    return true;
  } catch (err) {
    console.error(err);
    $("#saveStatus").textContent = "Save failed";
    if (!silent) alert("Could not save. Please try again.");
    saving = false;
    return false;
  }
}

async function completeAndReport() {
  if (!currentAssessment) return;
  if (readOnly) {
    showReport(currentAssessment);
    return;
  }
  capture();
  const blankScores = $$("[data-score]").filter((el) => el.value === "").length;
  if (blankScores > 10) {
    if (!confirm(`There are ${blankScores} unscored items. Complete the assessment anyway?`)) return;
  }
  currentAssessment.score_summary = scores(currentAssessment);
  currentAssessment.recommendation = readiness(currentAssessment.score_summary.total, currentAssessment.class_level);
  const ok = await saveAssessment(true, true);
  if (ok) {
    readOnly = true;
    $("#assessLockBanner").classList.remove("hidden");
    $("#saveBtn").disabled = true;
    $("#finishBtn").disabled = true;
    showReport(currentAssessment);
  }
}

/* -------------------- Records / dashboard -------------------- */

async function refreshDashboard() {
  const st = await store().stats();
  $("#studentCount").textContent = st.students;
  $("#assessmentCount").textContent = st.assessments;
  $("#completedCount").textContent = st.completed;
  $("#inProgressCount").textContent = st.in_progress;
  const rec = await store().listAssessments();
  renderTable($("#recentTable"), rec.slice(0, 8), true);
}

async function loadRecords() {
  const rec = await store().listAssessments();
  const q = ($("#recordSearch")?.value || "").toLowerCase();
  const st = $("#filterStatus")?.value || "";
  const cl = $("#filterClass")?.value || "";
  const filtered = rec.filter((x) => {
    const hay = `${x.student_name} class ${x.class_level} ${x.admission_year || ""} ${x.status}`.toLowerCase();
    if (q && !hay.includes(q)) return false;
    if (st && x.status !== st) return false;
    if (cl && String(x.class_level) !== cl) return false;
    return true;
  });
  renderTable($("#recordsTable"), filtered, true);
}

function renderTable(target, rec, actions) {
  if (!target) return;
  if (!rec.length) {
    target.innerHTML = '<p class="muted empty-state">No assessment records match your view yet. Start a new assessment to begin.</p>';
    return;
  }
  target.innerHTML = `<div class="table-wrap"><table>
    <thead><tr>
      <th>Student</th><th>Year</th><th>Class</th><th>Date</th><th>Status</th><th>Score</th>
      ${actions ? "<th>Actions</th>" : ""}
    </tr></thead>
    <tbody>${rec
      .map((a) => {
        const s = a.score_summary?.total ?? scores(a).total;
        return `<tr>
          <td>${esc(a.student_name)}</td>
          <td>${esc(a.admission_year || "—")}</td>
          <td>Primary ${a.class_level}</td>
          <td>${esc(a.assessment_date || "")}</td>
          <td><span class="status status-${esc(a.status || "in_progress")}">${esc(a.status || "in_progress")}</span></td>
          <td>${s}/120</td>
          ${
            actions
              ? `<td class="table-actions">
                  <button type="button" class="smallbtn" data-open="${a.id}">View report</button>
                  ${a.status !== "completed" ? `<button type="button" class="smallbtn" data-resume="${a.id}">Continue</button>` : ""}
                </td>`
              : ""
          }
        </tr>`;
      })
      .join("")}</tbody></table></div>`;
  target.querySelectorAll("[data-open]").forEach((b) => (b.onclick = () => openRecord(b.dataset.open)));
  target.querySelectorAll("[data-resume]").forEach((b) => (b.onclick = () => resumeRecord(b.dataset.resume)));
}

async function openRecord(id) {
  const a = await store().getAssessment(id);
  if (!a) {
    alert("Assessment not found.");
    return;
  }
  showReport(a);
}

async function resumeRecord(id) {
  const a = await store().getAssessment(id);
  if (!a) {
    alert("Assessment not found.");
    return;
  }
  if (a.status === "completed") {
    readOnly = true;
  } else {
    readOnly = false;
  }
  currentAssessment = a;
  dirty = false;
  selectedStudent = {
    id: a.student_id,
    full_name: a.student_name,
    dob: a.dob,
    age: a.age,
    guardian: a.guardian,
    previous_school: a.previous_school,
    home_language: a.home_language,
  };
  $$(".view").forEach((v) => v.classList.toggle("active", v.id === "new"));
  $$(".nav").forEach((n) => n.classList.toggle("active", n.dataset.view === "new"));
  const bank = BANK[String(a.class_level)];
  openAssessmentWorkspace(bank, a.student_name);
  Object.entries(a.responses || {}).forEach(([k, v]) => {
    let el;
    if (k.startsWith("score_")) el = $(`[data-score="${k.slice(6)}"]`);
    else el = $(`[data-response="${k}"]`);
    if (el) {
      el.value = v;
      if (el.matches("[data-score]") && v !== "") el.dataset.manualOverride = "1";
    }
  });
  if ($("#teacherNarrative")) $("#teacherNarrative").value = a.teacher_narrative || "";
  showAssessmentPage(0);
}

function showReport(a) {
  if (a === currentAssessment && !readOnly) {
    capture();
    a.score_summary = scores(a);
    a.recommendation = readiness(a.score_summary.total, a.class_level);
  }
  const s = a.score_summary?.total != null ? a.score_summary : scores(a);
  const recText = a.recommendation || readiness(s.total, a.class_level);
  const ds = [
    ["Mathematics", s.m],
    ["English/Literacy", s.e],
    ["Reasoning", s.rea],
    ["Motor/Writing", s.mo],
  ].sort((x, y) => x[1] - y[1]);
  const staffName = currentUser?.full_name || currentUser?.email || "Staff";

  $("#reportContent").innerHTML = `
    <div class="report-header">
      <div class="report-brand">Admissions Assessment Portal</div>
      <div class="report-sub">Primary Admissions Readiness Report</div>
    </div>
    <h1 id="reportHeading">Primary ${a.class_level} Admission Readiness Report</h1>
    <div class="report-meta">
      <div><strong>Student:</strong> ${esc(a.student_name)}</div>
      <div><strong>Admission year:</strong> ${esc(a.admission_year || "—")}</div>
      <div><strong>Class applied for:</strong> Primary ${esc(a.class_level)}</div>
      <div><strong>Assessment date:</strong> ${esc(a.assessment_date || "")}</div>
      <div><strong>Status:</strong> ${esc(a.status || "")}</div>
      <div><strong>Recorded by:</strong> ${esc(staffName)}</div>
    </div>
    <p class="report-rec"><strong>Recommendation:</strong> ${esc(recText)}</p>
    <div class="score-grid">
      ${[
        ["Mathematics", s.m],
        ["English", s.e],
        ["Reasoning", s.rea],
        ["Motor/Writing", s.mo],
        ["Overall", s.total],
      ]
        .map((x, i) => `<div class="score-card">${x[0]}<strong>${x[1]}/${i === 4 ? 120 : 30}</strong></div>`)
        .join("")}
    </div>
    <p><strong>Teacher observation average:</strong> ${esc(s.obsavg)}/3</p>
    <p><strong>Strongest assessed domain:</strong> ${esc(ds[3][0])}<br>
       <strong>Area for closest review:</strong> ${esc(ds[0][0])}</p>
    <h2>Teacher Observation</h2>
    <p class="report-narrative">${esc(a.teacher_narrative || "No narrative entered.")}</p>
    <div class="warning"><strong>Interpretation:</strong> Use the complete learner profile rather than the overall score alone. A lower domain score should prompt support or further assessment, not automatic rejection or a disability conclusion.</div>
    <p class="report-footer muted small">Generated by Admissions Assessment Portal • ${esc(today())}</p>`;
  $("#reportModal").classList.remove("hidden");
}

window.openRecord = openRecord;
window.resumeRecord = resumeRecord;

let interviewTimer = null;
function startInterviewAutosave() {
  stopInterviewAutosave();
  interviewTimer = setInterval(() => {
    if (currentAssessment && currentAssessment.status !== "completed" && dirty) {
      saveAssessment(false, true);
    }
  }, 8000);
}
function stopInterviewAutosave() {
  if (interviewTimer) clearInterval(interviewTimer);
  interviewTimer = null;
}

function emailParentReport() {
  if (!currentAssessment) return;
  const name = currentAssessment.student_name || "Student";
  const rec = currentAssessment.recommendation || "";
  const scores = currentAssessment.score_summary || {};
  const body = `Dear Parent/Guardian,%0A%0APlease find the admissions readiness summary for ${encodeURIComponent(name)}.%0A%0AAdmission year: ${encodeURIComponent(currentAssessment.admission_year || "")}%0AClass applied for: Primary ${encodeURIComponent(currentAssessment.class_level || "")}%0ARecommendation: ${encodeURIComponent(rec)}%0AOverall score: ${encodeURIComponent(scores.total || 0)}/120%0A%0AFor the full printable report, open the portal and use Print / Save as PDF.%0A%0A${encodeURIComponent((window.PORTAL_CONFIG && window.PORTAL_CONFIG.SCHOOL_NAME) || "School Admissions")}`;
  const to = (window.PORTAL_CONFIG && window.PORTAL_CONFIG.CONTACT_EMAIL) || "";
  window.location.href = `mailto:${to}?subject=${encodeURIComponent("Admissions readiness report — " + name)}&body=${body}`;
}

async function loadAcademicYears() {
  const box = $("#yearList");
  if (!box) return;
  try {
    const sb = await auth().getSupabaseClient();
    if (!sb) return;
    const { data, error } = await sb.from("admission_years").select("*").order("opened_at", { ascending: false });
    if (error) throw error;
    box.innerHTML = (data || []).map((y) => `${esc(y.year_label)} — <strong>${esc(y.status)}</strong>`).join("<br>") || "No years recorded yet.";
  } catch (err) {
    box.textContent = err.message || "Could not load years.";
  }
}

async function openAcademicYear() {
  const label = ($("#yearSetupInput")?.value || "").trim();
  if (!label) return notify($("#yearMsg"), "Enter a year label like 2027/2028.");
  try {
    const sb = await auth().getSupabaseClient();
    const { error } = await sb.from("admission_years").upsert({ year_label: label, status: "open", opened_at: new Date().toISOString(), archived_at: null });
    if (error) throw error;
    notify($("#yearMsg"), "Year opened: " + label, false);
    loadAcademicYears();
  } catch (err) {
    notify($("#yearMsg"), err.message || "Could not open year.");
  }
}

async function archiveAcademicYear() {
  const label = ($("#yearSetupInput")?.value || $("#admissionYear")?.value || "").trim();
  if (!label) return notify($("#yearMsg"), "Enter the year label to archive.");
  try {
    const sb = await auth().getSupabaseClient();
    const { error } = await sb.from("admission_years").upsert({ year_label: label, status: "archived", archived_at: new Date().toISOString() });
    if (error) throw error;
    notify($("#yearMsg"), "Year archived: " + label, false);
    loadAcademicYears();
  } catch (err) {
    notify($("#yearMsg"), err.message || "Could not archive year.");
  }
}

init();
