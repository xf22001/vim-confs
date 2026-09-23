// normalize-math snippet: markdown-it-katex (used by markdown-preview.nvim)
// only understands $...$ and $$...$$. LLMs usually emit \(...\) / \[...\].
// Normalize them here, before the buffer is sent to the browser.
// Line count is preserved so the sync-scroll mapping keeps working,
// and fenced code blocks are skipped.
function normalizeMath (lines) {
  if (!Array.isArray(lines)) return lines
  let inFence = false
  let fenceChar = ''
  return lines.map((line) => {
    const fence = line.match(/^\s*(`{3,}|~{3,})/)
    if (fence) {
      if (!inFence) {
        inFence = true
        fenceChar = fence[1][0]
      } else if (fence[1][0] === fenceChar) {
        inFence = false
        fenceChar = ''
      }
      return line
    }
    if (inFence) return line
    // display delimiters alone on a line -> $$
    if (/^\s*\\\[\s*$/.test(line)) return '$$'
    if (/^\s*\\\]\s*$/.test(line)) return '$$'
    // inline \(...\) -> $...$
    let out = line.replace(/\\\(([\s\S]*?)\\\)/g, (m, p) => `$${p}$`)
    // single-line \[...\] -> $$...$$
    out = out.replace(/\\\[([\s\S]*?)\\\]/g, (m, p) => `$$${p}$$`)
    return out
  })
}

