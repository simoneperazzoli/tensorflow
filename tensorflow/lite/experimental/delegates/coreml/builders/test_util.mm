/* Copyright 2019 The TensorFlow Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/
#include "tensorflow/lite/experimental/delegates/coreml/builders/test_util.h"

namespace tflite {
namespace delegates {
namespace coreml {

const char SingleOpModelWithCoreMlDelegate::kDelegateName[] = "TfLiteCoreMlDelegate";

void SingleOpModelWithCoreMlDelegate::ApplyDelegateAndInvoke() {
  auto* delegate_ptr = TfLiteCoreMlDelegateCreate(&params_);
  ASSERT_TRUE(delegate_ptr != nullptr);
  delegate_ = tflite::Interpreter::TfLiteDelegatePtr(
      delegate_ptr, [](TfLiteDelegate* delegate) { TfLiteCoreMlDelegateDelete(delegate); });
  // Add delegate.
  // TODO(karimnosseir): This doesn't actually make the test fail, switch to something else.
  ASSERT_TRUE(interpreter_->ModifyGraphWithDelegate(delegate_.get()) != kTfLiteError);

  Invoke();
}

}  // namespace coreml
}  // namespace delegates
}  // namespace tflite

@implementation BaseOpTest
- (void)validateInterpreter:(tflite::Interpreter*)interpreter {
  // Make sure we have valid interpreter.
  XCTAssertTrue(interpreter != nullptr);
  // Make sure graph has one Op which is the delegate node.
  XCTAssertEqual(interpreter->execution_plan().size(), 1);
  const int node_index = interpreter->execution_plan()[0];
  const auto* node_and_reg = interpreter->node_and_registration(node_index);
  XCTAssertTrue(node_and_reg != nullptr);
  XCTAssertTrue(node_and_reg->second.custom_name != nullptr);
  XCTAssertTrue(
      node_and_reg->second.custom_name ==
      std::string(tflite::delegates::coreml::SingleOpModelWithCoreMlDelegate::kDelegateName));
}

- (void)invokeAndValidate {
  _model->ApplyDelegateAndInvoke();
  [self validateInterpreter:_model->interpreter()];
}

@end
