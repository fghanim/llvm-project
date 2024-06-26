// RUN: mlir-tblgen -gen-op-defs -I %S/../../include %s | FileCheck %s
// RUN: mlir-tblgen -gen-op-decls -I %S/../../include %s | FileCheck %s --check-prefix=DECL

include "mlir/IR/OpBase.td"

def Test_Dialect : Dialect {
  let name = "test";
}
class NS_Op<string mnemonic, list<Trait> traits> :
    Op<Test_Dialect, mnemonic, traits>;

def OpA : NS_Op<"one_normal_operand_op", []> {
  let arguments = (ins I32:$input);
}

// CHECK-LABEL: OpA definitions

// CHECK:      OpAGenericAdaptorBase::OpAGenericAdaptorBase
// CHECK-SAME: odsAttrs(attrs)

// CHECK:      void OpA::build
// CHECK:        ::mlir::Value input
// CHECK:        odsState.addOperands(input);

// CHECK:      void OpA::build
// CHECK:        ::mlir::ValueRange operands
// CHECK:        assert(operands.size() == 1u && "mismatched number of parameters");
// CHECK:        odsState.addOperands(operands);

def OpB : NS_Op<"one_variadic_operand_op", []> {
  let arguments = (ins Variadic<I32>:$input);
}

// CHECK-LABEL: OpB::build
// CHECK:         ::mlir::ValueRange input
// CHECK-NOT:     assert
// CHECK:         odsState.addOperands(input);

def OpD : NS_Op<"mix_variadic_and_normal_inputs_op", [SameVariadicOperandSize]> {
  let arguments = (ins Variadic<AnyTensor>:$input1, AnyTensor:$input2, Variadic<AnyTensor>:$input3);
}

// DECL-LABEL: ::mlir::Operation::operand_range getInput1
// DECL-NEXT: return getODSOperands(0);

// DECL-LABEL: ::mlir::TypedValue<::mlir::TensorType> getInput2
// DECL-NEXT: return ::llvm::cast<::mlir::TypedValue<::mlir::TensorType>>(*getODSOperands(1).begin());

// CHECK-LABEL: OpD::build
// CHECK-NEXT: odsState.addOperands(input1);
// CHECK-NEXT: odsState.addOperands(input2);
// CHECK-NEXT: odsState.addOperands(input3);
