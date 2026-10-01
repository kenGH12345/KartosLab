import fs from 'node:fs';

const p = 'test/chemistry/build_a_nucleus/build_a_nucleus_state_test.dart';
const lines = fs.readFileSync(p, 'utf8').split('\n');

// 安全构造标识符，避免生成端再次损坏
const NE = 'Ne' + 'utron';
const addNe = 'add' + NE;          // addNeutron
const removeNe = 'remove' + NE;    // removeNeutron
const canAddNe = 'canAdd' + NE;    // canAddNeutron
const canRemoveNe = 'canRemove' + NE;

// 行号（1 基）→ 修复后整行内容。依据：state 文件真实标识符 + 原始测试意图。
const fixes = {
  34: `        expect(s.${addNe}(), isNotNull, reason: '${addNe} at \${s.protonCount},\${s.neutronCount}');`,
  77: `      expect(s.${removeNe}(), isTrue); // 回到 H-2`,
  85: `      expect(s.${removeNe}(), isFalse);`,
  94: `      expect(s.${canAddNe}, isTrue);`,
  96: `      expect(s.${canRemoveNe}, isFalse);`,
  101: `      s.${addNe}(); // (0,1) 自由中子，存在`,
  102: `      expect(s.${canAddNe}, isTrue); // 允许越界到 (0,2)`,
  103: `      s.${addNe}(); // (0,2) 不存在`,
  106: `      expect(s.${canAddNe}, isFalse);`,
  107: `      expect(s.${canRemoveNe}, isFalse);`,
  108: `      expect(s.${addNe}(), isNull); // 被规则拦截`,
  115: `      s.${addNe}(); // (1,1)`,
  237: `      expect(s.${removeNe}(), isTrue); // (7,6) N-13 存在`,
  251: `      s.${addNe}(); // (0,1) 存在`,
  252: `      s.${addNe}(); // (0,2) 不存在`,
};

for (const [lineNo, content] of Object.entries(fixes)) {
  const i = Number(lineNo) - 1;
  console.log(`L${lineNo}: ${lines[i].trim()}  ==>  ${content.trim()}`);
  lines[i] = content;
}

const out = lines.join('\n');
if (out.includes('<|')) throw new Error('markers remain');
fs.writeFileSync(p, out);
console.log('done. lines:', lines.length);
