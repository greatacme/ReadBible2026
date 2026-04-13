const http = require('http')
const https = require('https')
const { URL } = require('url')

const YOUVERSION_API_KEY = 'RNuGQ8nIJAkPojszfsd3VY3djsIAvxTaGAvs2YZkiA79VVjK'
const YOUVERSION_API_BASE = 'https://api.youversion.com/v1'

const server = http.createServer((req, res) => {
  // CORS 헤더 설정
  res.setHeader('Access-Control-Allow-Origin', '*')
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS')
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type')

  if (req.method === 'OPTIONS') {
    res.writeHead(200)
    res.end()
    return
  }

  if (req.method !== 'GET') {
    res.writeHead(405)
    res.end()
    return
  }

  try {
    const url = new URL(req.url, `http://localhost:8001`)
    const endpoint = url.pathname.replace('/youversion', '')
    const query = url.search

    const apiUrl = `${YOUVERSION_API_BASE}${endpoint}${query}`
    console.log(`[${new Date().toISOString()}] Proxying: ${apiUrl}`)

    const apiReqUrl = new URL(apiUrl)
    const options = {
      hostname: apiReqUrl.hostname,
      port: 443,
      path: apiReqUrl.pathname + apiReqUrl.search,
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'X-YVP-App-Key': YOUVERSION_API_KEY,
        'User-Agent': 'YouVersion-Proxy/1.0'
      }
    }

    const proxyReq = https.request(options, (proxyRes) => {
      console.log(`[${new Date().toISOString()}] Response status: ${proxyRes.statusCode}`)

      let responseBody = ''
      proxyRes.on('data', chunk => {
        responseBody += chunk.toString()
      })

      proxyRes.on('end', () => {
        if (proxyRes.statusCode !== 200 && proxyRes.statusCode !== 204) {
          console.log(`[${new Date().toISOString()}] Error response:`, responseBody)
        }

        const responseHeaders = {
          'Content-Type': proxyRes.headers['content-type'] || 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
        res.writeHead(proxyRes.statusCode, responseHeaders)
        res.end(responseBody)
      })
    })

    proxyReq.on('error', (e) => {
      console.error(`[${new Date().toISOString()}] API 요청 오류:`, e.message)
      res.writeHead(500, { 'Content-Type': 'application/json' })
      res.end(JSON.stringify({ error: e.message }))
    })

    proxyReq.end()
  } catch (e) {
    console.error(`[${new Date().toISOString()}] 서버 오류:`, e.message)
    res.writeHead(500, { 'Content-Type': 'application/json' })
    res.end(JSON.stringify({ error: e.message }))
  }
})

const PORT = 8001
server.listen(PORT, '0.0.0.0', () => {
  console.log(`YouVersion 프록시 서버가 포트 ${PORT}에서 실행 중입니다`)
  console.log(`로컬 요청: http://127.0.0.1:${PORT}/youversion/bibles?language_ranges[]=ko`)
})
