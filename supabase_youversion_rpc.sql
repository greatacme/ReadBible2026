-- Supabase RPC: YouVersion API 프록시 함수
-- 이 함수를 Supabase 대시보드의 SQL Editor에서 실행하세요

-- 1. http extension 활성화 (이미 설정되어 있으면 skip)
CREATE EXTENSION IF NOT EXISTS http;

-- 2. YouVersion Bible ID 조회 함수
CREATE OR REPLACE FUNCTION get_youversion_bibles()
RETURNS json AS $$
DECLARE
  result http_response;
BEGIN
  result := http((
    'GET',
    'https://api.youversion.com/v1/bibles?language_ranges[]=ko',
    ARRAY[http_header('X-YVP-App-Key', 'RNuGQ8nIJAkPojszfsd3VY3djsIAvxTaGAvs2YZkiA79VVjK')],
    NULL,
    NULL
  )::http_request);

  IF result.status != 200 THEN
    RAISE EXCEPTION 'YouVersion API returned status %', result.status;
  END IF;

  RETURN result.content::json;
END;
$$ LANGUAGE plpgsql;

-- 3. YouVersion 성경 장 조회 함수
CREATE OR REPLACE FUNCTION get_youversion_passage(
  p_bible_id text,
  p_passage_id text
)
RETURNS json AS $$
DECLARE
  result http_response;
  url text;
BEGIN
  url := 'https://api.youversion.com/v1/bibles/' || p_bible_id || '/passages/' || p_passage_id ||
         '?include_headings=false&include_notes=false&include_cross_references=false';

  result := http((
    'GET',
    url,
    ARRAY[http_header('X-YVP-App-Key', 'RNuGQ8nIJAkPojszfsd3VY3djsIAvxTaGAvs2YZkiA79VVjK')],
    NULL,
    NULL
  )::http_request);

  IF result.status != 200 THEN
    RAISE EXCEPTION 'YouVersion API returned status %', result.status;
  END IF;

  RETURN result.content::json;
END;
$$ LANGUAGE plpgsql;
