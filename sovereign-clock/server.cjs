
require('dotenv').config();
const express = require('express');
const fetch   = require('node-fetch');   // v2

const PORT = 5174;
const app  = express();

app.use(express.json());

app.post('/encourage', async (req, res) => {
  const { block } = req.body;
  console.log('➡️  /encourage  block =', block);

  try {
    const rsp = await fetch('https://api.openai.com/v1/chat/completions', {
      method : 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.OPENAI_KEY}`,
        'Content-Type' : 'application/json',
      },
      body: JSON.stringify({
        model       : 'gpt-4o-mini',
        max_tokens  : 40,
        temperature : 0.8,
        messages: [
          { role:'system', content:'你是一名中文励志教练，回答不超过25字。' },
          { role:'user',   content:`请鼓励我，现在在时间块 ${block}` },
        ],
      }),
    });

    const data = await rsp.json();
    console.log('⬅️  OpenAI status', rsp.status, JSON.stringify(data));

    if (!rsp.ok || !data.choices) {
      return res.status(500).json({ text:`OpenAI Error (${rsp.status})`, detail:data.error||data });
    }

    res.json({ text: data.choices[0].message.content.trim() });
  } catch (err) {
    console.error('❌  fetch error:', err);
    res.status(500).json({ text:'Server fetch error', detail: String(err) });
  }
});

app.listen(PORT, () => console.log(`✅  API listening → http://localhost:${PORT}`));
