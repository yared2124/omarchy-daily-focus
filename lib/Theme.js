/**
 * lib/Theme.js
 * NestJS inspired design system color palette:
 * - Signature NestJS Ruby Red (#e0234e / #f43f5e)
 * - Sleek dark slate & obsidian surfaces (#0e1017, #12131a, #181a24, #222436)
 * - Crisp contrast typography (#ffffff, #94a3b8, #64748b)
 * - Harmonious status semantics (Emerald #10b981, Amber #f59e0b, Sky #38bdf8)
 */

var THEME = {
  // Surfaces & Backgrounds
  bgDark: "#0e1017",
  bgPanel: "#12131a",
  bgCard: "#181a24",
  bgCardHover: "#222436",

  // Borders
  borderSubtle: "#2a2d3f",
  borderHover: "#3d4059",
  borderFocus: "#e0234e",

  // NestJS Brand Red
  primary: "#e0234e",
  primaryHover: "#f43f5e",
  primaryActive: "#c81e3a",
  primaryText: "#ffffff",

  // Typography
  textPrimary: "#ffffff",
  textSecondary: "#94a3b8",
  textMuted: "#64748b",

  // Status & Badges
  success: "#10b981",
  warning: "#f59e0b",
  info: "#38bdf8",
  danger: "#e0234e",

  // Progress Ring
  trackColor: "rgba(255, 255, 255, 0.10)"
};

if (typeof module !== 'undefined' && module.exports) {
  module.exports = { THEME };
}
