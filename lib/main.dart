import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: PowerPage(),
    );
  }
}

class PowerPage extends StatefulWidget {
  @override
  State<PowerPage> createState() => _PowerPageState();
}

class _PowerPageState extends State<PowerPage> {

  // =========================
  // CT / PT
  // =========================

  final ctPrimary = TextEditingController();
  final ctSecondary = TextEditingController();

  final ptPrimary = TextEditingController();
  final ptSecondary = TextEditingController();

  // =========================
  // Voltage
  // =========================

  final vr = TextEditingController();
  final vs = TextEditingController();
  final vt = TextEditingController();

  final vrAngle = TextEditingController();
  final vsAngle = TextEditingController();
  final vtAngle = TextEditingController();

  // =========================
  // Current
  // =========================

  final ir = TextEditingController();
  final isr = TextEditingController();
  final it = TextEditingController();

  final irAngle = TextEditingController();
  final isAngle = TextEditingController();
  final itAngle = TextEditingController();

  String result = "";

  // =========================
  // Degree → Radian
  // =========================

  double degToRad(double deg) {
    return deg * pi / 180;
  }

  // =========================
  // Ratio Input
  // =========================

  Widget ratioField(
    String title,
    TextEditingController primary,
    TextEditingController secondary,
    String unit,
  ) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        children: [

          SizedBox(
            width: 40,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 一次側
          Expanded(
            child: TextField(
              controller: primary,

              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),

              decoration: InputDecoration(
                labelText: "一次側",
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "$unit :",
              style: const TextStyle(fontSize: 18),
            ),
          ),

          // 二次側
          Expanded(
            child: TextField(
              controller: secondary,

              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),

              decoration: InputDecoration(
                labelText: "二次側",
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              unit,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // Value + Angle Row
  // =========================

  Widget fieldRow(
    String valueLabel,
    TextEditingController valueController,
    String angleLabel,
    TextEditingController angleController,
  ) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        children: [

          // 數值
          Expanded(
            child: TextField(
              controller: valueController,

              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),

              decoration: InputDecoration(
                labelText: valueLabel,
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // 角度
          Expanded(
            child: TextField(
              controller: angleController,

              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),

              decoration: InputDecoration(
                labelText: angleLabel,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // Single Phase Calculation
  // =========================

  Map<String, double> calcPhase(
    double v,
    double vAngle,
    double i,
    double iAngle,
  ) {

    // 相位差
    double theta = vAngle - iAngle;

    // PF
    double pf = cos(degToRad(theta));

    // P
    double p = v * i * pf;

    // Q
    double q = v * i * sin(degToRad(theta));

    // S
    double s = v * i;

    return {
      "pf": pf,
      "p": p,
      "q": q,
      "s": s,
      "theta": theta,
    };
  }

  // =========================
  // Calculate
  // =========================

  void calculate() {

    // =========================
    // CT/PT Ratio
    // =========================

    double ctRatio =
        (double.tryParse(ctPrimary.text) ?? 1) /
        (double.tryParse(ctSecondary.text) ?? 1);

    double ptRatio =
        (double.tryParse(ptPrimary.text) ?? 1) /
        (double.tryParse(ptSecondary.text) ?? 1);

    // =========================
    // Voltage
    // =========================

    double VR = (double.tryParse(vr.text) ?? 0) * ptRatio;
    double VS = (double.tryParse(vs.text) ?? 0) * ptRatio;
    double VT = (double.tryParse(vt.text) ?? 0) * ptRatio;

    // =========================
    // Current
    // =========================

    double IR = (double.tryParse(ir.text) ?? 0) * ctRatio;
    double IS = (double.tryParse(isr.text) ?? 0) * ctRatio;
    double IT = (double.tryParse(it.text) ?? 0) * ctRatio;

    // =========================
    // Angles
    // =========================

    double VRA = double.tryParse(vrAngle.text) ?? 0;
    double VSA = double.tryParse(vsAngle.text) ?? 0;
    double VTA = double.tryParse(vtAngle.text) ?? 0;

    double IRA = double.tryParse(irAngle.text) ?? 0;
    double ISA = double.tryParse(isAngle.text) ?? 0;
    double ITA = double.tryParse(itAngle.text) ?? 0;

    // =========================
    // Per Phase
    // =========================

    var r = calcPhase(VR, VRA, IR, IRA);
    var s = calcPhase(VS, VSA, IS, ISA);
    var t = calcPhase(VT, VTA, IT, ITA);

    // =========================
    // Total Power
    // =========================

    double totalP =
        (r["p"]! + s["p"]! + t["p"]!) / 1000000;

    double totalQ =
        (r["q"]! + s["q"]! + t["q"]!) / 1000000;

    double totalS =
        (r["s"]! + s["s"]! + t["s"]!) / 1000000;

    double totalPF =
        totalS == 0
            ? 0
            : totalP / totalS;

    // =========================
    // Leading / Lagging
    // =========================

    String leadLag =
        totalQ >= 0
            ? "落後 Lagging"
            : "超前 Leading";

    // =========================
    // Unbalance
    // =========================

    double avgI = (IR + IS + IT) / 3;

    double maxI = [IR, IS, IT].reduce(max);

    double minI = [IR, IS, IT].reduce(min);

    double unbalance =
        avgI == 0
            ? 0
            : ((maxI - minI) / avgI) * 100;

    // =========================
    // Result
    // =========================

    setState(() {

      result =
"""
========================
一次側實際值
========================

VR : ${VR.toStringAsFixed(2)} V
VS : ${VS.toStringAsFixed(2)} V
VT : ${VT.toStringAsFixed(2)} V

IR : ${IR.toStringAsFixed(2)} A
IS : ${IS.toStringAsFixed(2)} A
IT : ${IT.toStringAsFixed(2)} A

========================
功率分析
========================

P  : ${totalP.toStringAsFixed(3)} MW

Q  : ${totalQ.toStringAsFixed(3)} MVAR

S  : ${totalS.toStringAsFixed(3)} MVA

PF : ${totalPF.toStringAsFixed(4)}

狀態 : $leadLag


""";
    });
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("三相電力分析儀"),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // =========================
            // CT/PT
            // =========================

            const Text(
              "CT / PT 比例",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ratioField(
              "CT",
              ctPrimary,
              ctSecondary,
              "A",
            ),

            ratioField(
              "PT",
              ptPrimary,
              ptSecondary,
              "V",
            ),

            const SizedBox(height: 20),

            const Divider(),

            // =========================
            // Voltage
            // =========================

            const SizedBox(height: 20),

            const Text(
              "RST 電壓",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            fieldRow(
              "VR",
              vr,
              "∠VR",
              vrAngle,
            ),

            fieldRow(
              "VS",
              vs,
              "∠VS",
              vsAngle,
            ),

            fieldRow(
              "VT",
              vt,
              "∠VT",
              vtAngle,
            ),

            const SizedBox(height: 20),

            const Divider(),

            // =========================
            // Current
            // =========================

            const SizedBox(height: 20),

            const Text(
              "RST 電流",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            fieldRow(
              "IR",
              ir,
              "∠IR",
              irAngle,
            ),

            fieldRow(
              "IS",
              isr,
              "∠IS",
              isAngle,
            ),

            fieldRow(
              "IT",
              it,
              "∠IT",
              itAngle,
            ),

            const SizedBox(height: 30),

            // =========================
            // Button
            // =========================

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: calculate,

                child: const Padding(
                  padding: EdgeInsets.all(16),

                  child: Text(
                    "計算",
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // Result
            // =========================

            SelectableText(
              result,

              style: const TextStyle(
                fontSize: 20,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}