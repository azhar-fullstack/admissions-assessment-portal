/**
 * Shared Supabase helpers for all school portals.
 */
(function (global) {
  let client = null;

  function cfg() {
    return global.PORTAL_CONFIG || {};
  }

  function getClient() {
    if (client) return client;
    const c = cfg();
    if (!c.SUPABASE_URL || !c.SUPABASE_ANON_KEY || !global.supabase) {
      throw new Error("Portal config or Supabase library missing.");
    }
    client = global.supabase.createClient(c.SUPABASE_URL, c.SUPABASE_ANON_KEY, {
      auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true },
    });
    return client;
  }

  async function signUp({ email, password, full_name }) {
    const sb = getClient();
    return sb.auth.signUp({
      email: String(email || "").trim(),
      password: String(password || ""),
      options: { data: { full_name: full_name || "" } },
    });
  }

  async function signIn({ email, password }) {
    const sb = getClient();
    return sb.auth.signInWithPassword({
      email: String(email || "").trim(),
      password: String(password || ""),
    });
  }

  async function signOut() {
    return getClient().auth.signOut();
  }

  async function getUser() {
    const { data } = await getClient().auth.getUser();
    return data.user || null;
  }

  global.PortalShared = { cfg, getClient, signUp, signIn, signOut, getUser };
})(window);
