// File: utils/print_sizes.c
// Mục đích: Một công cụ dòng lệnh nhỏ để in ra thông tin kích thước (bytes)
// của các thuật toán KEM và Signature từ thư viện liboqs.
// Output được định dạng dưới dạng CSV để dễ dàng xử lý tự động.

#include <stdio.h>  // Thư viện chuẩn cho các hàm input/output (như printf)
#include <string.h> // Thư viện chuẩn cho các hàm xử lý chuỗi (như strcmp)
#include <oqs/oqs.h>  // File header chính của thư viện liboqs

/**
 * @brief Lấy thông tin về một thuật toán KEM và in ra các kích thước.
 * 
 * @param kem_name Tên của thuật toán KEM cần truy vấn.
 */
void print_kem_sizes(const char *kem_name) {
    // 1. Dùng hàm "nhà máy" của OQS để tạo một đối tượng KEM từ tên của nó.
    OQS_KEM *kem = OQS_KEM_new(kem_name);

    // 2. Kiểm tra xem thuật toán có tồn tại không. Nếu không, OQS_KEM_new sẽ trả về NULL.
    if (kem == NULL) {
        // In ra stderr để không làm ảnh hưởng đến output CSV chuẩn.
        fprintf(stderr, "Warning: KEM algorithm '%s' not found or not enabled.\n", kem_name);
        return; // Thoát hàm một cách nhẹ nhàng.
    }

    // 3. Truy cập trực tiếp các trường trong struct OQS_KEM và in ra theo định dạng CSV.
    // %s: string (chuỗi)
    // %zu: kiểu dữ liệu size_t (một kiểu số nguyên không dấu, thường dùng cho kích thước)
    // \n: ký tự xuống dòng
    printf("%s,%zu,%zu,%zu\n",
           kem->method_name,
           kem->length_public_key,
           kem->length_secret_key,
           kem->length_ciphertext);

    // 4. Giải phóng bộ nhớ đã được cấp phát cho đối tượng KEM để tránh memory leak.
    OQS_KEM_free(kem);
}

/**
 * @brief Lấy thông tin về một thuật toán Signature và in ra các kích thước.
 * 
 * @param sig_name Tên của thuật toán Signature cần truy vấn.
 */
void print_sig_sizes(const char *sig_name) {
    // Logic tương tự như hàm KEM
    OQS_SIG *sig = OQS_SIG_new(sig_name);
    if (sig == NULL) {
        fprintf(stderr, "Warning: Signature algorithm '%s' not found or not enabled.\n", sig_name);
        return;
    }

    // In ra các kích thước liên quan đến Signature
    printf("%s,%zu,%zu,%zu\n",
           sig->method_name,
           sig->length_public_key,
           sig->length_secret_key,
           sig->length_signature); // Chú ý: trường này là length_signature

    OQS_SIG_free(sig);
}

/**
 * @brief Điểm vào chính của chương trình.
 */
int main(int argc, char **argv) {
    // argc: argument count - số lượng tham số dòng lệnh (tên chương trình cũng là 1)
    // argv: argument vector - một mảng các chuỗi chứa các tham số
    // Ví dụ: ./print_sizes kem Kyber512 -> argc=3, argv[0]="./print_sizes", argv[1]="kem", argv[2]="Kyber512"
    
    // 1. Kiểm tra xem người dùng đã cung cấp đủ 3 tham số hay chưa.
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <kem|sig> <algorithm_name>\n", argv[0]);
        return 1; // Trả về mã lỗi 1
    }

    // 2. Khởi tạo thư viện OQS. Đây là bước bắt buộc.
    OQS_init();

    char *type = argv[1];     // Lấy loại thuật toán (kem hoặc sig)
    char *alg_name = argv[2]; // Lấy tên thuật toán

    // 3. Điều hướng đến hàm xử lý phù hợp. Dùng strcmp để so sánh chuỗi.
    if (strcmp(type, "kem") == 0) {
        print_kem_sizes(alg_name);
    } else if (strcmp(type, "sig") == 0) {
        print_sig_sizes(alg_name);
    } else {
        fprintf(stderr, "Error: Invalid type '%s'. Use 'kem' or 'sig'.\n", type);
    }

    // 4. Dọn dẹp và giải phóng tài nguyên của OQS.
    OQS_destroy();
    
    return 0; // Trả về 0 báo hiệu chương trình chạy thành công.
}
