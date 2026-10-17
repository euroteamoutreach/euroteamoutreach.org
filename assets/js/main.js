import Alpine from "alpinejs";

// Inline submit for a Netlify form (first user: contact-form.html; the /serve/
// gateway form will share it). Posts the form's own fields to Netlify as
// urlencoded data — the same payload as the no-JS POST — then swaps in the
// confirmation, which the form marks with x-ref="success". Netlify accepts an AJAX
// submission at "/" and routes it by the form-name field. HTML5 validation
// still runs first: @submit.prevent only fires once the browser's required and
// type="email" checks pass.
Alpine.data("netlifyForm", () => ({
  status: "idle", // idle → sending → sent | error

  async submit(event) {
    this.status = "sending";
    try {
      // A URLSearchParams body makes fetch send it urlencoded, header included.
      const response = await fetch("/", {
        method: "POST",
        body: new URLSearchParams(new FormData(event.target)),
      });
      this.status = response.ok ? "sent" : "error";
    } catch {
      this.status = "error"; // network failure
    }
    // On error the entries stay in the fields, so the visitor can just press
    // Send again.
    if (this.status === "sent")
      this.$nextTick(() => this.$refs.success.focus());
  },
}));

// Marks which [data-spy] section the reader is in (first user: the /doctrine/
// contents, where data-spy sits on each section's heading, the anchor target).
// `active` holds the id of the last marker whose top has scrolled past a line
// a quarter of the way down the window; that line sits below the 5rem where
// anchor jumps land, so a clicked section counts as current. At the very
// bottom the last section wins, even if it is too short to reach the line.
Alpine.data("scrollSpy", () => ({
  active: "",

  init() {
    const sections = [...this.$root.querySelectorAll("[data-spy]")];
    const update = () => {
      const line = window.innerHeight / 4;
      const atBottom =
        window.innerHeight + window.scrollY >=
        document.documentElement.scrollHeight - 2;
      const current = atBottom
        ? sections.at(-1)
        : sections.findLast((s) => s.getBoundingClientRect().top <= line);
      this.active = current?.id ?? "";
    };
    update();
    window.addEventListener("scroll", update, { passive: true });
  },
}));

// Bundled into the site via Hugo's js.Build (esbuild resolves this import from
// node_modules) — self-hosted, fingerprinted, and SRI-verified, rather than
// pulled from a CDN. Exposing window.Alpine is Alpine's documented ESM setup.
window.Alpine = Alpine;
Alpine.start();
