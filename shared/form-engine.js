/**
 * Dynamic form engine for meg_*_forms definition JSON.
 */
(function (global) {
  function escapeHtml(s) {
    return String(s ?? "").replace(/[&<>"']/g, (m) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[m]));
  }
  function escapeAttr(s) {
    return escapeHtml(s);
  }

  function shouldShow(q, answers) {
    if (!q.show_if) return true;
    return String(answers[q.show_if.key] || "") === String(q.show_if.equals);
  }

  function collectAnswers(root) {
    const answers = {};
    root.querySelectorAll("[data-key]").forEach((el) => {
      const key = el.getAttribute("data-key");
      if (el.type === "checkbox") {
        if (!Array.isArray(answers[key])) answers[key] = [];
        if (el.checked) answers[key].push(el.value);
        return;
      }
      const v = String(el.value || "").trim();
      if (v) answers[key] = v;
    });
    Object.keys(answers).forEach((k) => {
      if (Array.isArray(answers[k]) && !answers[k].length) delete answers[k];
    });
    return answers;
  }

  function applyVisibility(root, definition) {
    const answers = collectAnswers(root);
    (definition.questions || []).forEach((q) => {
      const card = root.querySelector(`[data-q="${CSS.escape(q.key)}"]`);
      if (!card) return;
      card.classList.toggle("hidden", !shouldShow(q, answers));
    });
  }

  function renderForm(definition, answers, mount) {
    const qs = [...(definition.questions || [])].sort((a, b) => (a.order || 0) - (b.order || 0));
    const a0 = answers || {};
    let html = "";
    if (definition.instructions) html += `<p class="muted">${escapeHtml(definition.instructions)}</p>`;
    if (definition.privacy_notice) {
      html += `<div class="panel" style="background:#f7f1e4"><strong>Privacy</strong><p class="muted">${escapeHtml(
        definition.privacy_notice
      )}</p></div>`;
    }
    let section = "";
    qs.forEach((q) => {
      if (q.section && q.section !== section) {
        section = q.section;
        html += `<h3 class="section-title">${escapeHtml(section)}</h3>`;
      }
      const req = q.required ? ' <span style="color:#9b2c2c">*</span>' : "";
      const help = q.help ? `<p class="muted" style="font-weight:400;margin:0.25rem 0 0">${escapeHtml(q.help)}</p>` : "";
      const val = a0[q.key];
      let field = "";
      if (q.type === "single") {
        field = `<select data-key="${q.key}"><option value="">Select</option>${(q.options || [])
          .map((o) => `<option value="${escapeAttr(o)}" ${val === o ? "selected" : ""}>${escapeHtml(o)}</option>`)
          .join("")}</select>`;
      } else if (q.type === "multi") {
        const selected = Array.isArray(val) ? val : [];
        field = `<div class="chip">${(q.options || [])
          .map(
            (o) =>
              `<label><input type="checkbox" data-key="${q.key}" value="${escapeAttr(o)}" ${
                selected.includes(o) ? "checked" : ""
              }> ${escapeHtml(o)}</label>`
          )
          .join("")}</div>`;
      } else if (q.type === "date") {
        field = `<input type="date" data-key="${q.key}" value="${escapeAttr(val || "")}">`;
      } else if (q.type === "email") {
        field = `<input type="email" data-key="${q.key}" value="${escapeAttr(val || "")}">`;
      } else if (q.type === "phone") {
        field = `<input type="tel" data-key="${q.key}" value="${escapeAttr(val || "")}">`;
      } else {
        field = `<textarea data-key="${q.key}" rows="2">${escapeHtml(val || "")}</textarea>`;
      }
      html += `<div class="q-card" data-q="${q.key}"><label>${escapeHtml(q.label)}${req}${help}${field}</label></div>`;
    });
    mount.innerHTML = html;
    applyVisibility(mount, definition);
    mount.addEventListener("change", () => applyVisibility(mount, definition));
    mount.addEventListener("input", () => applyVisibility(mount, definition));
  }

  global.FormEngine = { renderForm, collectAnswers };
})(window);
