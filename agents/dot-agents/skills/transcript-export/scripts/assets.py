"""Inline CSS + JS for exported transcripts.

Everything here is embedded directly into the generated HTML so a transcript is
a single self-contained file with no network requests.
"""

CSS = r"""
:root{
  --bg:#ffffff; --bg-alt:#f6f8fa; --bg-inset:#f0f3f6; --fg:#1f2328; --fg-muted:#59636e;
  --border:#d1d9e0; --border-soft:#e4e8ec; --accent:#0969da; --accent-soft:#ddf4ff;
  --user-bg:#f2f7fd; --user-border:#0969da; --asst-border:#8250df; --tool-bg:#f6f8fa;
  --ok:#1a7f37; --err:#cf222e; --warn:#9a6700; --code-bg:#f6f8fa; --code-fg:#1f2328;
  --add-bg:#e6ffec; --add-fg:#0f5323; --del-bg:#ffebe9; --del-fg:#82071e;
  --shadow:0 1px 3px rgba(31,35,40,.08); --radius:8px;
  --mono:ui-monospace,SFMono-Regular,"SF Mono",Menlo,Consolas,"Liberation Mono",monospace;
  --sans:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif;
}
html[data-theme="dark"]{
  --bg:#0d1117; --bg-alt:#151b23; --bg-inset:#0d1117; --fg:#e6edf3; --fg-muted:#9198a1;
  --border:#3d444d; --border-soft:#272c33; --accent:#4493f8; --accent-soft:#121d2f;
  --user-bg:#11192a; --user-border:#4493f8; --asst-border:#a371f7; --tool-bg:#151b23;
  --ok:#3fb950; --err:#f85149; --warn:#d29922; --code-bg:#161b22; --code-fg:#e6edf3;
  --add-bg:#0f2b16; --add-fg:#7ee787; --del-bg:#3c1618; --del-fg:#ffa198;
  --shadow:0 1px 3px rgba(1,4,9,.6);
}
*{box-sizing:border-box}
html{scroll-behavior:smooth}
body{
  margin:0; background:var(--bg); color:var(--fg); font-family:var(--sans);
  font-size:15px; line-height:1.6; -webkit-text-size-adjust:100%;
}
a{color:var(--accent); text-decoration:none}
a:hover{text-decoration:underline}

/* ---------- header ---------- */
header.top{
  position:sticky; top:0; z-index:50; background:var(--bg-alt);
  border-bottom:1px solid var(--border); backdrop-filter:saturate(1.4) blur(6px);
}
.top-inner{max-width:1600px; margin:0 auto; padding:10px 18px; display:flex; flex-wrap:wrap; gap:10px; align-items:center}
.title{font-size:15px; font-weight:600; margin:0; flex:1 1 320px; min-width:0;
  overflow:hidden; text-overflow:ellipsis; white-space:nowrap}
.title small{display:block; font-weight:400; color:var(--fg-muted); font-size:12px;
  overflow:hidden; text-overflow:ellipsis}
.controls{display:flex; flex-wrap:wrap; gap:6px; align-items:center}
.btn{
  font:inherit; font-size:12.5px; padding:5px 10px; border:1px solid var(--border);
  background:var(--bg); color:var(--fg); border-radius:6px; cursor:pointer; white-space:nowrap;
}
.btn:hover{background:var(--bg-inset)}
.btn[aria-pressed="true"]{background:var(--accent-soft); border-color:var(--accent); color:var(--accent)}
#search{
  font:inherit; font-size:13px; padding:5px 10px; border:1px solid var(--border);
  border-radius:6px; background:var(--bg); color:var(--fg); min-width:190px;
}
#search:focus{outline:2px solid var(--accent); outline-offset:-1px}
.hitcount{font-size:12px; color:var(--fg-muted); min-width:70px}

/* ---------- layout ---------- */
.wrap{max-width:1600px; margin:0 auto; display:grid; grid-template-columns:290px minmax(0,1fr); gap:26px; padding:20px 18px 80px}
@media (max-width:1000px){ .wrap{grid-template-columns:minmax(0,1fr)} nav.toc{display:none} }
nav.toc{position:sticky; top:64px; align-self:start; max-height:calc(100vh - 84px); overflow:auto;
  border:1px solid var(--border-soft); border-radius:var(--radius); background:var(--bg-alt); padding:10px}
nav.toc h2{font-size:11px; text-transform:uppercase; letter-spacing:.06em; color:var(--fg-muted); margin:4px 6px 8px}
nav.toc ol{list-style:none; margin:0; padding:0; counter-reset:tocitem}
nav.toc li{counter-increment:tocitem; margin:1px 0}
nav.toc a{display:block; padding:5px 8px 5px 26px; border-radius:6px; font-size:12.5px;
  color:var(--fg); position:relative; line-height:1.35; max-height:3.1em; overflow:hidden}
nav.toc a::before{content:counter(tocitem); position:absolute; left:6px; top:5px;
  color:var(--fg-muted); font-size:11px; font-variant-numeric:tabular-nums}
nav.toc a:hover{background:var(--bg-inset); text-decoration:none}
nav.toc a.active{background:var(--accent-soft); color:var(--accent); font-weight:600}

/* ---------- meta ---------- */
.meta-card{border:1px solid var(--border-soft); border-radius:var(--radius); background:var(--bg-alt);
  padding:14px 16px; margin-bottom:22px}
.meta-grid{display:grid; grid-template-columns:repeat(auto-fill,minmax(215px,1fr)); gap:8px 20px; margin:0}
.meta-grid div{font-size:12.5px; min-width:0}
.meta-grid dt{color:var(--fg-muted); font-size:11px; text-transform:uppercase; letter-spacing:.05em}
.meta-grid dd{margin:1px 0 0; word-break:break-word; font-family:var(--mono); font-size:12px}

/* ---------- messages ---------- */
.msg{border:1px solid var(--border-soft); border-radius:var(--radius); margin:0 0 14px;
  background:var(--bg); box-shadow:var(--shadow); overflow:hidden; scroll-margin-top:70px}
.msg.user{border-left:4px solid var(--user-border); background:var(--user-bg)}
.msg.peer{border-left:4px solid var(--ok); background:var(--bg-alt)}
.msg.peer .who{color:var(--ok)}
.msg.assistant{border-left:4px solid var(--asst-border)}
.msg.system{border-left:4px solid var(--fg-muted); background:var(--bg-alt)}
.msg.notice{border-left:4px solid var(--warn); background:var(--bg-alt)}
.msg.toolcall{border:0; background:none; box-shadow:none; margin:0 0 4px; border-radius:0}
.msg.toolcall > .body{padding:0 0 0 14px}
.msg.toolcall + .msg:not(.toolcall){margin-top:14px}
.msg-head{display:flex; gap:8px; align-items:center; padding:8px 14px; border-bottom:1px solid var(--border-soft);
  font-size:12px; color:var(--fg-muted); flex-wrap:wrap}
.who{font-weight:700; color:var(--fg); font-size:13px}
.msg.user .who{color:var(--user-border)}
.msg.assistant .who{color:var(--asst-border)}
.chip{font-size:11px; padding:1px 7px; border-radius:999px; background:var(--bg-inset);
  border:1px solid var(--border-soft); color:var(--fg-muted); font-family:var(--mono)}
.spacer{flex:1}
.body{padding:12px 16px}
.body > :first-child{margin-top:0}
.body > :last-child{margin-bottom:0}
.body p{margin:.55em 0}
.body h1,.body h2,.body h3,.body h4,.body h5,.body h6{margin:1.1em 0 .5em; line-height:1.3}
.body h1{font-size:1.5em; border-bottom:1px solid var(--border-soft); padding-bottom:.2em}
.body h2{font-size:1.28em; border-bottom:1px solid var(--border-soft); padding-bottom:.2em}
.body h3{font-size:1.12em} .body h4{font-size:1em}
.body ul,.body ol{margin:.5em 0; padding-left:1.6em}
.body li{margin:.18em 0}
.body ul.task-list{list-style:none; padding-left:1.1em}
.body blockquote{margin:.6em 0; padding:.1em 1em; border-left:3px solid var(--border);
  color:var(--fg-muted); background:var(--bg-alt); border-radius:0 6px 6px 0}
.body hr{border:0; border-top:1px solid var(--border); margin:1.2em 0}
.body img{max-width:100%}
code{font-family:var(--mono); font-size:.875em; background:var(--bg-inset);
  padding:.15em .4em; border-radius:5px; border:1px solid var(--border-soft)}
pre{margin:0; overflow:auto; padding:11px 13px; background:var(--code-bg); color:var(--code-fg);
  border-radius:6px; font-size:12.5px; line-height:1.5}
pre code{background:none; border:0; padding:0; font-size:inherit; white-space:pre}
.codewrap{position:relative; margin:.7em 0; border:1px solid var(--border-soft); border-radius:6px; overflow:hidden}
.code-lang{position:absolute; top:0; right:0; font:600 10px/1 var(--mono); letter-spacing:.05em;
  text-transform:uppercase; color:var(--fg-muted); background:var(--bg-alt);
  padding:4px 7px; border-left:1px solid var(--border-soft); border-bottom:1px solid var(--border-soft);
  border-radius:0 0 0 6px; pointer-events:none}
.copy{position:absolute; top:4px; right:4px; opacity:0; transition:opacity .12s; z-index:2;
  font:inherit; font-size:11px; padding:2px 7px; border:1px solid var(--border);
  background:var(--bg); color:var(--fg-muted); border-radius:5px; cursor:pointer}
.codewrap:hover .copy,.copy:focus{opacity:1}
.tablewrap{overflow-x:auto; margin:.7em 0}
table{border-collapse:collapse; font-size:13px; width:auto; min-width:min(100%,420px)}
th,td{border:1px solid var(--border); padding:5px 11px; text-align:left; vertical-align:top}
th{background:var(--bg-alt); font-weight:600}
tbody tr:nth-child(2n){background:var(--bg-alt)}

/* ---------- tools ---------- */
details.tool,details.think,details.sub{border:1px solid var(--border-soft); border-radius:6px;
  background:var(--tool-bg); margin:7px 0; overflow:hidden}
details.tool>summary,details.think>summary,details.sub>summary{
  cursor:pointer; padding:6px 12px; font-size:12.5px; display:flex; gap:8px; align-items:center;
  list-style:none; user-select:none; flex-wrap:nowrap}
details>summary::-webkit-details-marker{display:none}
details.tool>summary::before,details.think>summary::before,details.sub>summary::before{
  content:"\25B8"; color:var(--fg-muted); font-size:10px; transition:transform .12s; flex:none}
details[open]>summary::before{transform:rotate(90deg)}
details.tool>summary:hover,details.think>summary:hover{background:var(--bg-inset)}
.toolname{font-family:var(--mono); font-weight:600; font-size:12px; color:var(--accent); flex:none}
.toolsum{color:var(--fg-muted); overflow:hidden; text-overflow:ellipsis; white-space:nowrap;
  flex:1 1 auto; min-width:0; font-family:var(--mono); font-size:11.5px}
.status{font-size:11px; font-weight:700; flex:none}
.status.ok{color:var(--ok)} .status.err{color:var(--err)}
.tool-body{padding:2px 12px 11px; border-top:1px solid var(--border-soft)}
.tool-body .label{font-size:10.5px; text-transform:uppercase; letter-spacing:.06em;
  color:var(--fg-muted); margin:9px 0 3px; font-weight:600}
details.think{background:var(--bg-alt); border-style:dashed}
details.think .tool-body{color:var(--fg-muted); font-size:13.5px}
details.sub{margin-left:14px; border-left:3px solid var(--asst-border)}
.truncated{font-size:11.5px; color:var(--warn); margin-top:5px; font-style:italic}
.diff .add{background:var(--add-bg); color:var(--add-fg); display:block; min-height:1.5em}
.diff .del{background:var(--del-bg); color:var(--del-fg); display:block; min-height:1.5em}
.diff .hunk{color:var(--accent); display:block; min-height:1.5em}
.diff pre code>span{display:block; min-height:1.5em}
.turn-sep{display:flex; align-items:center; gap:10px; margin:26px 0 12px; color:var(--fg-muted); font-size:11px;
  text-transform:uppercase; letter-spacing:.08em}
.turn-sep::before,.turn-sep::after{content:""; height:1px; background:var(--border-soft); flex:1}
mark{background:#fff3a3; color:#1f2328; border-radius:2px; padding:0 1px}
html[data-theme="dark"] mark{background:#9e6a03; color:#fff}
footer.bot{max-width:1600px; margin:0 auto; padding:16px 18px 40px; color:var(--fg-muted); font-size:11.5px;
  border-top:1px solid var(--border-soft)}

/* ---------- filters ---------- */
body:not(.show-tools) .msg.toolcall{display:none}
body:not(.show-system) .msg.system{display:none}
body:not(.show-think) details.think{display:none}
.msg.hidden-by-search{display:none !important}
.empty-state{padding:26px; text-align:center; color:var(--fg-muted)}

@media print{
  header.top,nav.toc,.copy,.controls{display:none !important}
  .wrap{display:block; padding:0; max-width:none}
  body{font-size:11pt}
  .msg{break-inside:avoid; box-shadow:none; border:1px solid #ccc}
  details{open:open}
  details>summary::before{display:none}
  pre{white-space:pre-wrap; word-break:break-word}
}
"""

JS = r"""
(function(){
  var root = document.documentElement, body = document.body;
  var KEY = 'copilot-transcript-prefs';
  var prefs = {};
  try { prefs = JSON.parse(localStorage.getItem(KEY) || '{}'); } catch(e) { prefs = {}; }

  function save(){ try { localStorage.setItem(KEY, JSON.stringify(prefs)); } catch(e){} }

  if (prefs.theme) root.setAttribute('data-theme', prefs.theme);
  else if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches)
    root.setAttribute('data-theme','dark');

  function syncToggle(btn){
    var cls = btn.getAttribute('data-class');
    var on = body.classList.contains(cls);
    btn.setAttribute('aria-pressed', on ? 'true' : 'false');
  }
  Array.prototype.forEach.call(document.querySelectorAll('[data-class]'), function(btn){
    var cls = btn.getAttribute('data-class');
    if (prefs[cls] === true) body.classList.add(cls);
    if (prefs[cls] === false) body.classList.remove(cls);
    syncToggle(btn);
    btn.addEventListener('click', function(){
      body.classList.toggle(cls);
      prefs[cls] = body.classList.contains(cls);
      save(); syncToggle(btn);
    });
  });

  var themeBtn = document.getElementById('theme-btn');
  if (themeBtn) themeBtn.addEventListener('click', function(){
    var next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
    root.setAttribute('data-theme', next); prefs.theme = next; save();
  });

  function allDetails(){ return document.querySelectorAll('details'); }
  var expandBtn = document.getElementById('expand-btn');
  if (expandBtn) expandBtn.addEventListener('click', function(){
    var opening = expandBtn.getAttribute('data-state') !== 'open';
    Array.prototype.forEach.call(allDetails(), function(d){ d.open = opening; });
    expandBtn.setAttribute('data-state', opening ? 'open' : 'closed');
    expandBtn.textContent = opening ? 'Collapse all' : 'Expand all';
  });

  var printBtn = document.getElementById('print-btn');
  if (printBtn) printBtn.addEventListener('click', function(){
    Array.prototype.forEach.call(allDetails(), function(d){ d.open = true; });
    window.print();
  });

  /* copy buttons for code blocks */
  Array.prototype.forEach.call(document.querySelectorAll('.codewrap'), function(wrap){
    var btn = document.createElement('button');
    btn.className = 'copy'; btn.type = 'button'; btn.textContent = 'Copy';
    btn.addEventListener('click', function(){
      var code = wrap.querySelector('code');
      var text = code ? code.textContent : '';
      var done = function(){ btn.textContent = 'Copied'; setTimeout(function(){ btn.textContent='Copy'; }, 1200); };
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(done, function(){});
      } else {
        var ta = document.createElement('textarea');
        ta.value = text; document.body.appendChild(ta); ta.select();
        try { document.execCommand('copy'); done(); } catch(e){}
        document.body.removeChild(ta);
      }
    });
    wrap.appendChild(btn);
  });

  /* search / filter */
  var search = document.getElementById('search');
  var hits = document.getElementById('hitcount');
  var msgs = Array.prototype.slice.call(document.querySelectorAll('.msg'));
  msgs.forEach(function(m){ m._text = (m.textContent || '').toLowerCase(); });
  var timer = null;

  function clearMarks(scope){
    Array.prototype.forEach.call(scope.querySelectorAll('mark'), function(mk){
      var p = mk.parentNode;
      p.replaceChild(document.createTextNode(mk.textContent), mk);
      p.normalize();
    });
  }
  function markText(node, needle){
    var walker = document.createTreeWalker(node, NodeFilter.SHOW_TEXT, null);
    var found = [], n;
    while ((n = walker.nextNode())) {
      if (n.nodeValue.toLowerCase().indexOf(needle) !== -1 &&
          n.parentNode.nodeName !== 'SCRIPT' && n.parentNode.nodeName !== 'STYLE') found.push(n);
      if (found.length > 400) break;
    }
    found.forEach(function(t){
      var frag = document.createDocumentFragment(), rest = t.nodeValue, idx;
      var lower = rest.toLowerCase();
      var pos = 0;
      while ((idx = lower.indexOf(needle, pos)) !== -1) {
        if (idx > pos) frag.appendChild(document.createTextNode(rest.slice(pos, idx)));
        var mk = document.createElement('mark');
        mk.textContent = rest.slice(idx, idx + needle.length);
        frag.appendChild(mk);
        pos = idx + needle.length;
      }
      if (pos < rest.length) frag.appendChild(document.createTextNode(rest.slice(pos)));
      t.parentNode.replaceChild(frag, t);
    });
  }
  function runSearch(){
    var q = (search.value || '').trim().toLowerCase();
    clearMarks(document.querySelector('main'));
    if (!q) {
      msgs.forEach(function(m){ m.classList.remove('hidden-by-search'); });
      hits.textContent = '';
      return;
    }
    var count = 0;
    msgs.forEach(function(m){
      var match = m._text.indexOf(q) !== -1;
      m.classList.toggle('hidden-by-search', !match);
      if (match) {
        count++;
        markText(m, q);
        Array.prototype.forEach.call(m.querySelectorAll('details'), function(d){
          if ((d.textContent||'').toLowerCase().indexOf(q) !== -1) d.open = true;
        });
      }
    });
    hits.textContent = count + (count === 1 ? ' block' : ' blocks');
  }
  if (search) {
    search.addEventListener('input', function(){
      clearTimeout(timer); timer = setTimeout(runSearch, 140);
    });
    search.addEventListener('keydown', function(e){
      if (e.key === 'Escape') { search.value = ''; runSearch(); search.blur(); }
    });
  }
  document.addEventListener('keydown', function(e){
    if ((e.key === '/' || (e.key === 'f' && (e.metaKey || e.ctrlKey) && e.shiftKey)) &&
        document.activeElement !== search) {
      e.preventDefault(); search.focus(); search.select();
    }
  });

  /* TOC active-state tracking */
  var links = Array.prototype.slice.call(document.querySelectorAll('nav.toc a'));
  var targets = links.map(function(a){ return document.getElementById(a.getAttribute('href').slice(1)); })
                     .filter(Boolean);
  if (window.IntersectionObserver && targets.length) {
    var seen = {};
    var io = new IntersectionObserver(function(entries){
      entries.forEach(function(en){ seen[en.target.id] = en.isIntersecting; });
      var activeId = null;
      for (var i = 0; i < targets.length; i++) if (seen[targets[i].id]) { activeId = targets[i].id; break; }
      links.forEach(function(a){
        a.classList.toggle('active', activeId && a.getAttribute('href') === '#' + activeId);
      });
    }, { rootMargin: '-70px 0px -70% 0px' });
    targets.forEach(function(t){ io.observe(t); });
  }
})();
"""
