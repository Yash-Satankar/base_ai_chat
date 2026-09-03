/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,jsx}"],
  theme: {
    extend: {
      colors: {
        // layered near-blacks — never pure #000
        bg: {
          DEFAULT:  "#0a0a0c",
          raised:   "#0e0e11",
          elevated: "#141417",
          overlay:  "#1a1a1e",
          input:    "#0c0c0f",
        },
        line: {
          DEFAULT: "rgba(255,255,255,0.06)",
          strong:  "rgba(255,255,255,0.11)",
        },
        ink: {
          DEFAULT: "#ededf0",
          muted:   "#a1a1aa",
          dim:     "#71717a",
          faint:   "#52525b",
        },
        // one accent, used sparingly
        accent: {
          DEFAULT: "#8b7cf8",
          hi:      "#a89bff",
          bg:      "rgba(139,124,248,0.10)",
          line:    "rgba(139,124,248,0.32)",
          ring:    "rgba(139,124,248,0.45)",
        },
        ok:     { DEFAULT: "#3ecf8e", bg: "rgba(62,207,142,0.10)", line: "rgba(62,207,142,0.28)" },
        warn:   { DEFAULT: "#f5a623", bg: "rgba(245,166,35,0.10)", line: "rgba(245,166,35,0.28)" },
        danger: { DEFAULT: "#f56565", bg: "rgba(245,101,101,0.10)", line: "rgba(245,101,101,0.28)" },
      },
      fontFamily: {
        sans: ["Inter", "system-ui", "-apple-system", "Segoe UI", "sans-serif"],
        mono: ['"JetBrains Mono"', "ui-monospace", "SFMono-Regular", "monospace"],
      },
      letterSpacing: {
        tightest: "-0.03em",
      },
      boxShadow: {
        "inset-hl": "inset 0 1px 0 0 rgba(255,255,255,0.05)",
        lift: "0 1px 2px rgba(0,0,0,0.5), 0 10px 30px -14px rgba(0,0,0,0.65)",
        pop: "0 20px 60px -16px rgba(0,0,0,0.75), 0 0 0 1px rgba(255,255,255,0.06)",
        "glow-accent": "0 0 0 1px rgba(139,124,248,0.35), 0 8px 30px -8px rgba(139,124,248,0.25)",
      },
      keyframes: {
        "fade-up":   { "0%": { opacity: "0", transform: "translateY(6px)" }, "100%": { opacity: "1", transform: "translateY(0)" } },
        "fade-in":   { "0%": { opacity: "0" }, "100%": { opacity: "1" } },
        "scale-in":  { "0%": { opacity: "0", transform: "scale(0.97)" }, "100%": { opacity: "1", transform: "scale(1)" } },
        drift:       { "0%,100%": { transform: "translate(-2%,-1%) scale(1)" }, "50%": { transform: "translate(2%,3%) scale(1.08)" } },
        sheen:       { "0%": { transform: "translateX(-140%)" }, "100%": { transform: "translateX(240%)" } },
        dot:         { "0%,80%,100%": { opacity: ".2", transform: "translateY(0)" }, "40%": { opacity: "1", transform: "translateY(-3px)" } },
        marquee:     { "0%": { marginLeft: "-45%" }, "100%": { marginLeft: "100%" } },
      },
      animation: {
        "fade-up":  "fade-up .24s cubic-bezier(0.16,1,0.3,1)",
        "fade-in":  "fade-in .2s ease-out",
        "scale-in": "scale-in .16s cubic-bezier(0.16,1,0.3,1)",
        drift:      "drift 24s ease-in-out infinite",
        sheen:      "sheen 2.6s ease-in-out infinite",
        marquee:    "marquee 1.4s linear infinite",
      },
    },
  },
  plugins: [],
}
