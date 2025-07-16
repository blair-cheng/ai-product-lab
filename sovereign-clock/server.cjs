/* server.cjs —— 带完整日志的最终版 */
require("dotenv").config();
const express = require("express");
const fetch = require("node-fetch");

const PORT = 5174;
const app = express();

app.use(express.json());
app.use(express.static("dist"));

app.post("/encourage", async (req, res) => {
  const { block } = req.body;
  console.log("➡️  /encourage called, block =", block);

  try {
    /* 1. 调 OpenAI */
    const openaiRes = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${process.env.OPENAI_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        max_tokens: 40,
        temperature: 0.8,
        messages: [
          {
            role: "system",
            content: "你是一名中文励志教练，回答不超过25字。",
          },
          { role: "user", content: `请鼓励我，现在在时间块 ${block}` },
        ],
      }),
    });

    const data = await openaiRes.json();

    /* 2. 打完整日志 */
    console.log(
      `⬅️  OpenAI status ${openaiRes.status}`,
      JSON.stringify(data)
    );

    if (!openaiRes.ok) {
      /* 把 OpenAI 错误透传给前端，方便观察 */
      return res
        .status(500)
        .json({ text: `OpenAI Error (${openaiRes.status})`, detail: data });
    }

    /* 3. 正常返回鼓励句 */
    res.json({ text: data.choices[0].message.content.trim() });
  } catch (err) {
    /* fetch自身或网络错误 */
    console.error("❌ Fetch error:", err);
    res.status(500).json({ text: "Server fetch error", detail: err + "" });
  }
});

app.listen(PORT, () =>
  console.log(`✅ API listening → http://localhost:${PORT}`)
);
