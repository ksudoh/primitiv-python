#include <config.h>

#include <stdexcept>
#include <vector>
#include <gtest/gtest.h>
#include <primitiv/cuda_device.h>
#include <primitiv/shape.h>
#include <primitiv/tensor.h>
#include <test_utils.h>

using std::vector;
using test_utils::vector_match;

namespace primitiv {

class CUDADeviceTest : public testing::Test {};

TEST_F(CUDADeviceTest, CheckInvalidNew) {
  EXPECT_THROW(CUDADevice dev(12345678), std::runtime_error);
}

TEST_F(CUDADeviceTest, CheckNewDelete) {
  {
    CUDADevice dev(0);
    Tensor x1 = dev.new_tensor(Shape()); // 1 value
    Tensor x2 = dev.new_tensor(Shape {16, 16}); // 256 values
    Tensor x3 = dev.new_tensor(Shape({16, 16, 16}, 16)); // 65536 values
    // According to the C++ standard, local values are destroyed in the order:
    // x3 -> x2 -> x1 -> dev.
    // Then `dev` has no remaining memories.
  }
  SUCCEED();
}

TEST_F(CUDADeviceTest, CheckInvalidNewDelete) {
  EXPECT_DEATH({
    Tensor x0;
    CUDADevice dev(0);
    x0 = dev.new_tensor(Shape());
    // Local values are destroyed in the order: dev -> x0.
    // `x0` still have a memory when destroying `dev` and the process will
    // abort.
  }, "");
}

TEST_F(CUDADeviceTest, CheckSetValuesByConstant) {
  CUDADevice dev(0);
  {
    Tensor x = dev.new_tensor(Shape({2, 2}, 2), 42);
    EXPECT_TRUE(vector_match(vector<float>(8, 42), x.to_vector()));
  }
  {
    Tensor x = dev.new_tensor(Shape({2, 2}, 2));
    x.reset(42);
    EXPECT_TRUE(vector_match(vector<float>(8, 42), x.to_vector()));
  }
}

TEST_F(CUDADeviceTest, CheckSetValuesByVector) {
  CUDADevice dev(0);
  {
    const vector<float> data {1, 2, 3, 4, 5, 6, 7, 8};
    Tensor x = dev.new_tensor(Shape({2, 2}, 2), data);
    EXPECT_TRUE(vector_match(data, x.to_vector()));
  }
  {
    const vector<float> data {1, 2, 3, 4, 5, 6, 7, 8};
    Tensor x = dev.new_tensor(Shape({2, 2}, 2));
    x.reset(data);
    EXPECT_TRUE(vector_match(data, x.to_vector()));
  }
}

}  // namespace primitiv