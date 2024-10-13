const path = require('path');
const { exec } = require('child_process');
const { connectToNetworkorg } = require('../../sever-managent/controllers/network'); // Chỉnh đường dẫn tùy theo cấu trúc thư mục của bạn


exports.updateOrganizationStatus = async (tokeorg) => {
    console.log(tokeorg); // Sử dụng biến tokeorg

    let gateway;
    try {
        const { contract, gateway: gw } = await connectToNetworkorg();
        gateway = gw;

        const newStatus = true;
        const currentTime = new Date();

        // Cập nhật trạng thái tổ chức
        const updateResult = await contract.submitTransaction("updateOrganizationStatus", tokeorg, newStatus, currentTime.toISOString());
        
        if (updateResult) {
            console.log("Transaction result:", updateResult.toString());
            // Trả về kết quả khi transaction hoàn tất
            return { status: true, output: updateResult.toString() }; // Chuyển đổi kết quả thành đối tượng
        } else {
            console.error("Update result is undefined");
            return null; // Trả về null nếu không có kết quả
        }
    } catch (error) {
        console.error(`Failed to submit transaction: ${error.message}`);
        return null; // Trả về null trong trường hợp lỗi
    } finally {
        if (gateway) {
            try {
                await gateway.disconnect(); // Đảm bảo gọi disconnect để giải phóng tài nguyên
            } catch (disconnectError) {
                console.error(`Failed to disconnect gateway: ${disconnectError.message}`);
            }
        }
    }
};