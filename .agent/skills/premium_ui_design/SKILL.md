---
name: Premium UI Design Expert
description: 用於建立現代化、高質感、具備微動畫與絕佳視覺體驗的使用者介面設計指南。
---

# Premium UI Design Expert

當使用者要求建立或優化 UI 時，你必須嚴格遵守以下所有設計準則，以確保產出具備頂級質感的介面。不可產出陽春或僅達「堪用」標準的 MVP 介面。

## 1. 核心視覺與色彩 (Color & Aesthetics)
- **禁用基礎色**：絕對不要使用原生的純色（如 `#FF0000`, `blue`, `green`）。
- **色彩系統**：使用現代的色彩學（如 HSL 配色）。建立包含主色 (Primary)、次色 (Secondary)、背景色 (Background)、表面色 (Surface) 與文字色 (Text) 的系統。
- **漸層與光影**：適度運用平滑漸層（Smooth Gradients）與柔和的陰影（Soft Shadows / Drop shadows）來建立層次感。
- **毛玻璃效果 (Glassmorphism)**：在適合的地方（如導覽列、彈出視窗、浮動卡片）使用半透明背景結合 `backdrop-filter: blur()`。

## 2. 佈局與空間 (Layout & Spacing)
- **留白 (Whitespace)**：給予元素充足的呼吸空間，加大 padding 與 margin，避免擁擠。
- **響應式網格**：使用 Flexbox 或 CSS Grid 確保介面在各種螢幕尺寸下都能完美呈現。
- **圓角 (Border Radius)**：統一使用現代感的圓角設計（例如卡片使用 `12px` 或 `16px`，按鈕使用 `8px` 或全圓角）。

## 3. 字體排版 (Typography)
- **現代字體**：引入現代無襯線字型（如 Inter, Roboto, Outfit, 或 Noto Sans TC）。
- **清晰的層級**：透過字重 (Font weight)、大小 (Size) 與不透明度 (Opacity) 來區分標題、副標題與內文。
- **行高與字距**：設定適當的 `line-height`（內文推薦 1.5 - 1.7）與 `letter-spacing`。

## 4. 互動與微動畫 (Interactions & Micro-animations)
- **極致平滑**：所有狀態改變（Hover, Focus, Active）都必須有轉場動畫（例如 `transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);`）。
- **反饋感**：按鈕與卡片在 Hover 時應有微小的位移（如 `transform: translateY(-2px)`）或陰影加深；被點擊時要有縮放效果（`scale(0.98)`）。
- **骨架屏 (Skeleton Loading)**：資料載入時使用帶有微光掃過動畫的骨架屏，而非單調的 Loading 圓圈。

## 5. 實作規範 (Implementation Rules)
1. **先建置 Design System**：在開始寫元件前，先在 CSS (或 Tailwind config / Theme provider) 中定義好所有的 CSS 變數 (Colors, Spacing, Typography)。
2. **無佔位符**：如果需要圖像，請使用 `generate_image` 工具生成有質感的模擬圖案，不要放空白區塊。
3. **無障礙兼顧**：確保顏色對比度足夠，且所有互動元素都有清晰的 focus 狀態。
