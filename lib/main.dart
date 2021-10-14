import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluthereum',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Fluthereum'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Client httpClient;
  Web3Client ethereumClient;
  TextEditingController controller = TextEditingController();

  String rpcUrl = 'http://127.0.0.1:7545';

  int totalBalance = 0, userBalance = 0;
  bool loading = false;

  Map<String, String> privateKeys = {
    'User 1':
        'b3a6c36dd862bd7ad3f6fd24977d47d3fd5dada6b255bea24e4753ee5d30bcb6',
    'User 2': '0f690abf475f27aee10347df845b334eadac96921cb35126aab682e2ac1affad'
  };
  String privateKeySelected = 'User 1';
  EthPrivateKey credential;
  EthereumAddress appAddress;
  String abi;
  EthereumAddress ehtereumContractAddress;
  DeployedContract contract;
  ContractFunction getBalanceAmount,
      getDepositAmount,
      addDepositAmount,
      withDrawBalance,
      testeTuga,
      getBalanceByAddress;

  Future<void> getDeployedContract() async {
    String abiString = await rootBundle.loadString('src/abis/Fluthereum.json');
    var abiJson = jsonDecode(abiString);
    abi = jsonEncode(abiJson['abi']);

    ehtereumContractAddress =
        EthereumAddress.fromHex(abiJson['networks']['5777']['address']);
  }

  Future<void> getCredentials() async {
    credential = EthPrivateKey.fromHex(privateKeys[privateKeySelected]);
    appAddress = await credential.extractAddress();
  }

  Future<void> getContractFunctions() async {
    contract = DeployedContract(
        ContractAbi.fromJson(abi, "Fluthereum"), ehtereumContractAddress);

    getBalanceAmount = contract.function('getBalanceAmount');
    getDepositAmount = contract.function('getDepositAmount');
    addDepositAmount = contract.function('addDepositAmount');
    getBalanceByAddress = contract.function('getBalanceByAddress');
    withDrawBalance = contract.function('withDrawBalance');
  }

  Future<List<dynamic>> readContract(
      ContractFunction functionName, List<dynamic> functionArgs) async {
    try {
      manageLoading();
      var queryResult = await ethereumCall(functionName, functionArgs);
      print("Result from Contract call of ${functionName.name} ->" +
          queryResult.toList().toString());
      manageLoading();
      return queryResult;
    } catch (e) {
      print(e.toString());
      manageLoading();
    }
    return [];
  }

  void manageLoading() {
    return setState(() {
      loading = !loading;
    });
  }

  Future<List<dynamic>> ethereumCall(
      ContractFunction functionName, List<dynamic> functionArgs) async {
    return await ethereumClient.call(
        contract: contract, function: functionName, params: functionArgs);
  }

  Future<void> writeContract(
      ContractFunction functionName, List<dynamic> functionArgs) async {
    var queryResult = await ethereumClient.sendTransaction(
      credential,
      Transaction.callContract(
        contract: contract,
        function: functionName,
        parameters: functionArgs,
      ),
    );

    print(queryResult.toString());
  }

  @override
  void initState() {
    super.initState();
    initialSetup();
  }

  Future<void> initialSetup() async {
    httpClient = Client();
    ethereumClient = Web3Client(rpcUrl, httpClient);
    await getCredentials();
    await getDeployedContract();
    await getContractFunctions();
    updateValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("User private Key: "),
                DropdownButton<String>(
                  value: privateKeySelected,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      privateKeySelected = newValue;
                      getCredentials();
                      updateValues();
                    });
                  },
                  items: privateKeys.keys
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Total Balance",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange),
                      ),
                      loading
                          ? CircularProgressIndicator()
                          : Text(
                              totalBalance.toString(),
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w500),
                            ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "User Balance",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      loading
                          ? CircularProgressIndicator()
                          : Text(
                              userBalance.toString(),
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w500),
                            ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Text(
                    "Amount to Deposit",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: IconButton(
                    onPressed: () async {
                      await updateValues();
                    },
                    icon: Icon(Icons.refresh),
                    color: Colors.white,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: IconButton(
                    onPressed: () async {
                      await writeContract(addDepositAmount, [
                        BigInt.from(int.parse(
                            controller.text.isEmpty ? "3" : controller.text)),
                        appAddress
                      ]);
                      updateValues();
                    },
                    icon: Icon(Icons.upload),
                    color: Colors.white,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: IconButton(
                    onPressed: () async {
                      await writeContract(withDrawBalance, [appAddress]);
                      updateValues();
                    },
                    icon: Icon(Icons.download),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  Future<void> updateValues() async {
    List<dynamic> totalBalanceResult = await readContract(getBalanceAmount, []);
    List<dynamic> addressBalanceResult =
        await readContract(getBalanceByAddress, [appAddress]);

    setState(() {
      totalBalance = totalBalanceResult?.first?.toInt();
      userBalance = addressBalanceResult?.first?.toInt();
    });
  }
}
