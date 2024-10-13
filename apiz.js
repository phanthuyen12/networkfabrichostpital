const express = require('express');
const { exec } = require('child_process');
const path = require('path');
const orgController = require('./apinetwork/controller/orgController');
const app = express();
const port = 3333;

// Middleware to parse JSON request bodies
app.use(express.json());
app.get('/hello', orgController.hello);
app.post('/creater', orgController.createOrg);

// Endpoint to run shell script
app.post('/run-script', (req, res) => {
  const value = req.body.value; // Nhận giá trị từ yêu cầu
  console.log(value);

  if (value === undefined) {
    return res.status(400).json({ error: 'No value provided' });
  }
console.log(__dirname)
  const scriptPath = path.join(__dirname, 'tudong.sh'); // Đường dẫn đến file .sh

  // Chạy shell script với giá trị truyền vào
  exec(`bash ${scriptPath} ${value}`, (error, stdout, stderr) => {
    if (error) {
      console.error(`exec error: ${error}`);
      return res.status(500).json({ error: 'Script execution failed', details: stderr });
    }
    
    // Trả về kết quả khi script hoàn tất
    console.log('thành công ')
    res.json({ status: "true", output: stdout });
  });
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
