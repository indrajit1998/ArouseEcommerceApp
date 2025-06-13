import 'package:flutter/material.dart';

class EmiCalculator extends StatelessWidget {
  const EmiCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("EMI Calculator"),
          Row(
            children: [
              Text("Total Amount: "),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Type Total Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
          Row(
            children: [
              Text("Paid Amount: "),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Paid Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
          Row(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'How many Months to pay',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              )
            ],
          ),
          
        ],
      ),
    );
  }
}