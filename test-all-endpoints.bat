@echo off
echo ========================================
echo Testing All Backend API Endpoints
echo ========================================
echo.

echo 1. Testing GET /api/health...
curl -s http://192.168.1.25:8000/api/health
echo.
echo.

echo 2. Testing GET /api/v1/stores...
curl -s http://192.168.1.25:8000/api/v1/stores | jq ".success, .count"
echo.
echo.

echo 3. Testing GET /api/v1/stores/30/products...
curl -s http://192.168.1.25:8000/api/v1/stores/30/products | jq ".success, .count"
echo.
echo.

echo 4. Testing POST /api/v1/stores...
curl -s -X POST http://192.168.1.25:8000/api/v1/stores ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"Test Store\",\"phone\":\"9999999999\"}" | jq ".success, .message"
echo.
echo.

echo 5. Testing POST /api/v1/products...
curl -s -X POST http://192.168.1.25:8000/api/v1/products ^
  -H "Content-Type: application/json" ^
  -d "{\"store_id\":30,\"name\":\"Test Product\",\"price\":99.99}" | jq ".success, .message"
echo.
echo.

echo ========================================
echo All Tests Complete!
echo ========================================
pause
