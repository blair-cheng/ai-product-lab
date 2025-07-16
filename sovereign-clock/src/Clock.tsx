// src/HandDrawnClock.tsx
import { useState } from "react";
import clockBg from "./assets/clock_bg.png"; // 确保图片在 src/assets 目录

/* 各扇形起止角度（单位°，09:00 顶部 = -90°） */
const sectors = [
  { id: 1, deg: [-90, 30] },  // 深紫区 09–10
  { id: 2, deg: [30, 110] },  // 粉紫区 10–12
  { id: 3, deg: [110, 160] }, // 浅黄/绿 12–15
  { id: 4, deg: [160, 240] }, // 天蓝/浅绿 15–18
  { id: 5, deg: [240, 285] }, // 浅橙 18–21
  { id: 6, deg: [285, 360] }, // 粉色 21–24（wrap 到 0°）
];

export default function HandDrawnClock() {
  const [msg, setMsg] = useState("点一块试试看");

  return (
    <>
      <div style={{ position: "relative", width: 320, height: 320 }}>
        {/* 手绘 PNG 背景 */}
        <img
          src={clockBg}
          alt="15h clock"
          style={{ width: "100%", height: "100%" }}
        />

        {/* 点击热点层 (SVG 全透明) */}
        <svg
          viewBox="-160 -160 320 320"
          style={{ position: "absolute", top: 0, left: 0 }}
        >
          {sectors.map(({ id, deg }) => {
            const [start, end] = deg;
            const path = describeArc(0, 0, 150, start, end);
            return (
              <path
                key={id}
                d={path}
                fill="transparent"
                style={{ cursor: "pointer" }}
                onClick={() => handleClick(id, setMsg)}
              />
            );
          })}
        </svg>
      </div>
      <p style={{ marginTop: 8 }}>{msg}</p>

      <style>{`
        path:hover { filter: brightness(1.1); }
      `}</style>
    </>
  );
}

/* 点击处理：先提示“生成中…”，再调用后端，失败时用本地兜底句 */
async function handleClick(block: number, setMsg: (s: string) => void) {
  setMsg("生成中…");
  try {
    const res = await fetch("http://localhost:5174/encourage", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ block }),
    });
    const { text } = await res.json();
    setMsg(text);
  } catch (e) {
    console.error(e);
    const fallback = [
      "深呼吸，你做得很好！",
      "喝口水，再冲五分钟！",
      "慢一点，也在进步🌱",
    ];
    setMsg(fallback[Math.floor(Math.random() * fallback.length)]);
  }
}

/* 工具函数 —— 角度转 SVG 扇形路径 */
function polarToCartesian(cx: number, cy: number, r: number, deg: number) {
  const rad = ((deg - 90) * Math.PI) / 180;
  return { x: cx + r * Math.cos(rad), y: cy + r * Math.sin(rad) };
}
function describeArc(cx: number, cy: number, r: number, start: number, end: number) {
  const s = polarToCartesian(cx, cy, r, end);
  const e = polarToCartesian(cx, cy, r, start);
  const largeArc = end - start <= 180 ? 0 : 1;
  return `M ${s.x} ${s.y} A ${r} ${r} 0 ${largeArc} 0 ${e.x} ${e.y} L ${cx} ${cy} Z`;
}
