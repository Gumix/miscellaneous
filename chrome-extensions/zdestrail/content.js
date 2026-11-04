(() => {
  const API = "https://admin.gdetrail.ru/api/trails/json";
  const LICENSE = "CC BY-SA 4.0 https://creativecommons.org/licenses/by-sa/4.0/";
  let dataPromise = null;

  const loadData = () =>
    (dataPromise ||= fetch(API).then((r) => {
      if (!r.ok) throw new Error("HTTP " + r.status);
      return r.json();
    }).catch((e) => { dataPromise = null; throw e; }));

  const esc = (s) => String(s ?? "").replace(/[&<>"]/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));

  const parseIds = (v) => {
    if (typeof v === "string") { try { v = JSON.parse(v); } catch { v = []; } }
    return v || [];
  };

  function toGpx(t, data) {
    const builders = new Map(data.builders.map((b) => [b.id, b.name]));
    const region = data.regions.find((r) => String(r.id) === String(t.region))?.name;
    const authors = parseIds(t.creator_ids).map((i) => builders.get(i)).filter(Boolean).join(", ");
    const desc = [t.brief_description, t.type, region,
      authors && "Авторы: " + authors,
      `https://karta.gdetrail.ru/?trail=${t.id}`].filter(Boolean).join(" | ");
    const pts = t.trk_seg.map((p) =>
      `<trkpt lat="${p.lat}" lon="${p.lon}">${p.ele != null ? `<ele>${p.ele}</ele>` : ""}</trkpt>`);
    return `<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="gdetrail-gpx-extension" xmlns="http://www.topografix.com/GPX/1/1">
<metadata><name>${esc(t.name)}</name><desc>${esc(desc)}</desc><copyright author="${esc(authors || "Где трейл")}"><license>${esc(LICENSE)}</license></copyright></metadata>
<trk><name>${esc(t.name)}</name><trkseg>
${pts.join("\n")}
</trkseg></trk></gpx>
`;
  }

  const currentId = () => new URLSearchParams(location.search).get("trail");

  async function download(btn) {
    const id = currentId();
    if (!id) return;
    const label = btn.textContent;
    btn.disabled = true;
    btn.textContent = "Загрузка…";
    try {
      const data = await loadData();
      const t = data.trails.find((x) => String(x.id) === id);
      if (!t || !t.trk_seg?.length) throw new Error("трек не найден");
      const blob = new Blob([toGpx(t, data)], { type: "application/gpx+xml" });
      const a = document.createElement("a");
      a.href = URL.createObjectURL(blob);
      a.download = `${id}_${t.name.replace(/[\\/:*?"<>|\s]+/g, "_")}.gpx`;
      document.body.appendChild(a);
      a.click();
      a.remove();
      setTimeout(() => URL.revokeObjectURL(a.href), 10000);
    } catch (e) {
      alert("Не удалось скачать GPX: " + e.message);
    } finally {
      btn.disabled = false;
      btn.textContent = label;
    }
  }

  function inject() {
    if (!currentId()) return;
    for (const panel of document.querySelectorAll(".trail-info")) {
      if (panel.querySelector(".gt-gpx-btn")) continue;
      const btn = document.createElement("button");
      btn.className = "gt-gpx-btn";
      btn.type = "button";
      btn.textContent = "Скачать GPX";
      btn.addEventListener("click", () => download(btn));
      panel.insertBefore(btn, panel.firstChild);
    }
  }

  new MutationObserver(inject).observe(document.body, { childList: true, subtree: true });
  inject();
})();
