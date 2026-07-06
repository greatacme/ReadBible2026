const http = require('http')
const fs = require('fs')
const path = require('path')

const rootDir = __dirname

function loadEnvFile() {
  const envPath = path.join(rootDir, '.env')
  if (!fs.existsSync(envPath)) return

  const lines = fs.readFileSync(envPath, 'utf8').split(/\r?\n/)
  for (const line of lines) {
    const trimmed = line.trim()
    if (!trimmed || trimmed.startsWith('#')) continue

    const eqIndex = trimmed.indexOf('=')
    if (eqIndex === -1) continue

    const key = trimmed.slice(0, eqIndex).trim()
    const value = trimmed.slice(eqIndex + 1).trim().replace(/^["']|["']$/g, '')
    if (key && process.env[key] === undefined) process.env[key] = value
  }
}

loadEnvFile()

const port = Number(process.env.PORT || 3000)
const youVersionBaseUrl = process.env.YOUVERSION_BASE_URL || 'https://api.youversion.com/v1'
const youVersionApiKey = process.env.YOUVERSION_API_KEY || ''

const mimeTypes = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.ico': 'image/x-icon',
  '.svg': 'image/svg+xml; charset=utf-8',
  '.txt': 'text/plain; charset=utf-8'
}

function sendJson(res, status, payload) {
  res.writeHead(status, {
    'content-type': 'application/json; charset=utf-8',
    'access-control-allow-origin': '*'
  })
  res.end(JSON.stringify(payload))
}

function serveStatic(req, res, pathname) {
  const relativePath = pathname === '/' ? '/index.html' : pathname
  const requestedPath = path.normalize(decodeURIComponent(relativePath)).replace(/^(\.\.[/\\])+/, '')
  const filePath = path.join(rootDir, requestedPath)

  if (!filePath.startsWith(rootDir)) {
    sendJson(res, 403, { error: 'Forbidden' })
    return
  }

  fs.readFile(filePath, (err, content) => {
    if (err) {
      sendJson(res, 404, { error: 'Not found' })
      return
    }

    const ext = path.extname(filePath).toLowerCase()
    res.writeHead(200, { 'content-type': mimeTypes[ext] || 'application/octet-stream' })
    res.end(content)
  })
}

async function proxyYouVersion(req, res, url) {
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'access-control-allow-origin': '*',
      'access-control-allow-methods': 'GET, OPTIONS',
      'access-control-allow-headers': 'content-type'
    })
    res.end()
    return
  }

  if (req.method !== 'GET') {
    sendJson(res, 405, { error: 'Method not allowed' })
    return
  }

  if (!youVersionApiKey) {
    sendJson(res, 500, { error: 'YOUVERSION_API_KEY is not set' })
    return
  }

  const target = `${youVersionBaseUrl.replace(/\/$/, '')}${url.pathname}${url.search}`

  try {
    const upstream = await fetch(target, {
      headers: {
        'accept': 'application/json',
        'X-YVP-App-Key': youVersionApiKey
      }
    })

    const body = await upstream.text()
    res.writeHead(upstream.status, {
      'content-type': upstream.headers.get('content-type') || 'application/json; charset=utf-8',
      'access-control-allow-origin': '*'
    })
    res.end(body)
  } catch (err) {
    sendJson(res, 502, { error: 'YouVersion proxy request failed', detail: err.message })
  }
}

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || `127.0.0.1:${port}`}`)

  if (url.pathname.startsWith('/youversion/')) {
    url.pathname = url.pathname.replace(/^\/youversion/, '')
    proxyYouVersion(req, res, url)
    return
  }

  serveStatic(req, res, url.pathname)
})

server.listen(port, '127.0.0.1', () => {
  console.log(`ReadBible2026 server: http://127.0.0.1:${port}/`)
  console.log('YouVersion proxy: /youversion/*')
})
