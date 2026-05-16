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
  // Input Field
  // =========================

  Widget field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: TextField(
        controller: controller,

        // iPhone 可輸入小數點與負號
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),

        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
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

    // θ = V角 - I角
    double theta = vAngle - iAngle;

    // PF
    double pf = cos(degToRad(theta));

    // W
    double p = v * i * pf;

    // VAR
    double q = v * i * sin(degToRad(theta));

    // VA
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
  // Main Calculate
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
    // Actual Voltage
    // =========================

    double VR = (double.tryParse(vr.text) ?? 0) * ptRatio;
    double VS = (double.tryParse(vs.text) ?? 0) * ptRatio;
    double VT = (double.tryParse(vt.text) ?? 0) * ptRatio;

    // =========================
    // Actual Current
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
    // Total
    // =========================

    // MW
    double totalMW =
        (r["p"]! + s["p"]! + t["p"]!) / 1000000;

    // MVAR
    double totalMVAR =
        (r["q"]! + s["q"]! + t["q"]!) / 1000000;

    // MVA
    double totalMVA =
        (r["s"]! + s["s"]! + t["s"]!) / 1000000;

    // PF
    double totalPF =
        totalMVA == 0
            ? 0
            : totalMW / totalMVA;

    // Leading / Lagging
    String leadLag =
        totalMVAR >= 0
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
真實一次側
========================

VR : ${VR.toStringAsFixed(2)} V
VS : ${VS.toStringAsFixed(2)} V
VT : ${VT.toStringAsFixed(2)} V

IR : ${IR.toStringAsFixed(2)} A
IS : ${IS.toStringAsFixed(2)} A
IT : ${IT.toStringAsFixed(2)} A

========================
功率
========================

P  : ${totalMW.toStringAsFixed(3)} MW

Q  : ${totalMVAR.toStringAsFixed(3)} MVAR

S  : ${totalMVA.toStringAsFixed(3)} MVA

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
              "CT / PT",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            field("CT 一次側", ctPrimary),
            field("CT 二次側", ctSecondary),

            field("PT 一次側", ptPrimary),
            field("PT 二次側", ptSecondary),

            const SizedBox(height: 20),

            const Divider(),

            // =========================
            // Voltage
            // =========================

            const Text(
              "三相 電壓",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            field("Va", vr),
            field("∠Va", vrAngle),

            field("Vb", vs),
            field("∠Vb", vsAngle),

            field("Vc", vt),
            field("∠Vc", vtAngle),

            const SizedBox(height: 20),

            const Divider(),

            // =========================
            // Current
            // =========================

            const Text(
              "三相 電流",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            field("Ia", ir),
            field("∠Ia", irAngle),

            field("Ib", isr),
            field("∠Ib", isAngle),

            field("Ic", it),
            field("∠Ic", itAngle),

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
                    style: TextStyle(fontSize: 20),
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
          ],
        ),
      ),
    );
  }
}