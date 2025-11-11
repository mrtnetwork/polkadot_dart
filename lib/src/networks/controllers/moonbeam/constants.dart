class MoonbeamNetworkControllerConst {
  static const int erc20BrdigePalletIndex = 110;
  static const int moonbaseErc20BrdigePalletIndex = 3;
  static const List<int> moonbeamAssetIdPrefix = [0xff, 0xff, 0xff, 0xff];
  static final BigInt moonbaseChainId = BigInt.from(1287);
  static final BigInt moonbeamChainId = BigInt.from(1284);
  static final BigInt moonRiverChainId = BigInt.from(1285);
  static List<Map<String, dynamic>> defaultAssets(BigInt chainId) {
    if (chainId == moonbaseChainId) {
      return _moonBaseAssets;
    } else if (chainId == moonbeamChainId) {
      return _moonbeamAssets;
    } else if (chainId == moonRiverChainId) {
      return _moonRiverAssets;
    }
    return [];
  }

  static const List<Map<String, dynamic>> _moonbeamAssets = [
    {
      "asset_id": "112675423039561305557350799263187182338",
      "name": "Bridged MOVR",
      "symbol": "MOVR.mr",
      "decimals": "18",
      "location": "0502030903009d1f040a"
    },
    {
      "asset_id": "78407957940239408223554844611219482002",
      "name": "Moonriver",
      "symbol": "xcibcMOVR",
      "decimals": "18",
      "location": "050103008d1f043b052717000000000000000000000001"
    },
    {
      "asset_id": "150874409661081770150564009349448205842",
      "name": "Zeitgeist",
      "symbol": "xcZTG",
      "decimals": "10",
      "location":
          "05010200b12006020001000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "283870493414747423842723289889816153538",
      "name": "Unique Network",
      "symbol": "xcUNQ",
      "decimals": "18",
      "location": "05010100d51f"
    },
    {
      "asset_id": "90225766094594282577230355136633846906",
      "name": "Polkadex",
      "symbol": "xcPDEX",
      "decimals": "12",
      "location": "05010100e11f"
    },
    {
      "asset_id": "178794693648360392906933130845919698647",
      "name": "Snowbridge WETH",
      "symbol": "WETH.e",
      "decimals": "18",
      "location": "0502020907040300c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
    },
    {
      "asset_id": "314077021455772878282433861213184736939",
      "name": "peaq",
      "symbol": "xcPEAQ",
      "decimals": "18",
      "location": "050101002934"
    },
    {
      "asset_id": "144012926827374458669278577633504620722",
      "name": "Bifrost Filecoin Native Token",
      "symbol": "xcFIL",
      "decimals": "18",
      "location":
          "05010200b91f06020804000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "66249247788835743307843320271452141931",
      "name": "Bifrost Voucher BNC",
      "symbol": "xcvBNC",
      "decimals": "12",
      "location":
          "05010200b91f06020101000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "125699734534028342599692732320197985871",
      "name": "Darwinia Parachain Token",
      "symbol": "xcRING",
      "decimals": "18",
      "location": "05010200f91f0405"
    },
    {
      "asset_id": "91372035960551235635465443179559840483",
      "name": "Centrifuge",
      "symbol": "xcCFG",
      "decimals": "18",
      "location":
          "05010200bd1f06020001000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "220698173844663170714431919474506717455",
      "name": "Circle EURC (Stellar)",
      "symbol": "xcEURC.s",
      "decimals": "12",
      "location":
          "05010500b92004350508060445555243000000000000000000000000000000000000000000000000000000000620cf4f5a26e2090bb3adcf02c7a9d73dbfe6659cc690461475b86437fa49c71136"
    },
    {
      "asset_id": "187224307232923873519830480073807488153",
      "name": "Equilibrium Dollar",
      "symbol": "xcEQD",
      "decimals": "9",
      "location":
          "050102006d1f06036571640000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "124105859028862849477017063633156007283",
      "name": "Snowbridge wstETH",
      "symbol": "wstETH.e",
      "decimals": "18",
      "location": "05020209070403007f39c581f595b53c5cb19bd0b3f8da6c935e2ca0"
    },
    {
      "asset_id": "69606720909260275826784788104880799692",
      "name": "HydraDX",
      "symbol": "xcHDX",
      "decimals": "12",
      "location": "05010200c91f0500"
    },
    {
      "asset_id": "133307414193833606001516599592873928539",
      "name": "Celestia",
      "symbol": "xcibcTIA",
      "decimals": "6",
      "location": "050103008d1f043b052713000000000000000000000001"
    },
    {
      "asset_id": "294342517635293430510451841925413680520",
      "name": "LAOS",
      "symbol": "xcLAOS",
      "decimals": "18",
      "location": "05010100a934"
    },
    {
      "asset_id": "190590555344745888270686124937537713878",
      "name": "Equilibrium Token",
      "symbol": "xcEQ",
      "decimals": "9",
      "location": "050101006d1f"
    },
    {
      "asset_id": "61295607754960722617854661686514597014",
      "name": "dog wif dots",
      "symbol": "xcWIFD",
      "decimals": "10",
      "location": "05010300a10f04320544"
    },
    {
      "asset_id": "141196559012917796508928734717797136690",
      "name": "Inter Stable Token",
      "symbol": "xcibcIST",
      "decimals": "6",
      "location": "050103008d1f043b052719000000000000000000000001"
    },
    {
      "asset_id": "29085784439601774464560083082574142143",
      "name": "Bifrost Voucher DOT",
      "symbol": "xcvDOT",
      "decimals": "10",
      "location":
          "05010200b91f06020900000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "225719522181998468294117309041779353812",
      "name": "Acala Liquid DOT",
      "symbol": "xcLDOT",
      "decimals": "10",
      "location":
          "05010200411f06020003000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "36282181791341254438422467838694599751",
      "name": "Snowbridge WBTC",
      "symbol": "WBTC.e",
      "decimals": "8",
      "location": "05020209070403002260fac5e5542a773aa44fbcfedf7c193bc2c599"
    },
    {
      "asset_id": "124463719055550872076363892993240202694",
      "name": "DED",
      "symbol": "xcDED",
      "decimals": "10",
      "location": "05010300a10f04320578"
    },
    {
      "asset_id": "224077081838586484055667086558292981199",
      "name": "Astar",
      "symbol": "xcASTR",
      "decimals": "18",
      "location": "05010100591f"
    },
    {
      "asset_id": "199907282886248358976504623107230837230",
      "name": "Agoric",
      "symbol": "xcibcBLD",
      "decimals": "6",
      "location": "050103008d1f043b052712000000000000000000000001"
    },
    {
      "asset_id": "209858003230988836317829383377338889687",
      "name": "Snowbridge DAI",
      "symbol": "DAI.e",
      "decimals": "18",
      "location": "05020209070403006b175474e89094c44da98b954eedeac495271d0f"
    },
    {
      "asset_id": "166377000701797186346254371275954761085",
      "name": "USD Coin",
      "symbol": "xcUSDC",
      "decimals": "6",
      "location": "05010300a10f043205e514"
    },
    {
      "asset_id": "142155548796783636521833385094843759961",
      "name": "bncs-20 inscription token BNCS",
      "symbol": "xcBNCS",
      "decimals": "12",
      "location":
          "05010200b91f06020809000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "29822050060168568866953499393406221037",
      "name": "Snowbridge USDC",
      "symbol": "USDC.e",
      "decimals": "6",
      "location": "0502020907040300a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"
    },
    {
      "asset_id": "89994634370519791027168048838578580624",
      "name": "Subsocial",
      "symbol": "xcSUB",
      "decimals": "10",
      "location": "05010100d520"
    },
    {
      "asset_id": "138280378441551394289980644963240827219",
      "name": "Cosmos Hub",
      "symbol": "xcibcATOM",
      "decimals": "6",
      "location": "050103008d1f043b052707000000000000000000000001"
    },
    {
      "asset_id": "228510780171552721666262089780561563481",
      "name": "Picasso",
      "symbol": "xcibcPICA",
      "decimals": "12",
      "location": "050103008d1f043b052701000000000000000000000001"
    },
    {
      "asset_id": "204507659831918931608354793288110796652",
      "name": "Bifrost Voucher GLMR",
      "symbol": "xcvGLMR",
      "decimals": "18",
      "location":
          "05010200b91f06020901000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "184218609779515850660274730699350567246",
      "name": "Apillon",
      "symbol": "xcNCTR",
      "decimals": "18",
      "location": "05010300a10f0432050110"
    },
    {
      "asset_id": "289989900872525819559124583375550296953",
      "name": "Bifrost Voucher MANTA",
      "symbol": "xcvMANTA",
      "decimals": "18",
      "location":
          "05010200b91f06020908000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "110021739665376159354538090254163045594",
      "name": "Acala Dollar",
      "symbol": "xcaUSD",
      "decimals": "12",
      "location":
          "05010200411f06020001000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "311091173110107856861649819128533077277",
      "name": "Tether USD",
      "symbol": "xcUSDT",
      "decimals": "6",
      "location": "05010300a10f043205011f"
    },
    {
      "asset_id": "64174511183114006009298114091987195453",
      "name": "PINK",
      "symbol": "xcPINK",
      "decimals": "10",
      "location": "05010300a10f0432055c"
    },
    {
      "asset_id": "309163521958167876851250718453738106865",
      "name": "Nodle",
      "symbol": "xcNODL",
      "decimals": "11",
      "location": "05010200a91f0402"
    },
    {
      "asset_id": "120637696315203257380661607956669368914",
      "name": "interBTC",
      "symbol": "xcIBTC",
      "decimals": "8",
      "location":
          "05010200c11f06020001000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "166446646689194205559791995948102903873",
      "name": "Manta",
      "symbol": "xcMANTA",
      "decimals": "18",
      "location": "05010100e120"
    },
    {
      "asset_id": "101170542313601871197860408087030232491",
      "name": "Interlay",
      "symbol": "xcINTR",
      "decimals": "10",
      "location":
          "05010200c11f06020002000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "165823357460190568952172802245839421906",
      "name": "BNC",
      "symbol": "xcBNC",
      "decimals": "12",
      "location":
          "05010200b91f06020001000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "32615670524745285411807346420584982855",
      "name": "PARA",
      "symbol": "xcPARA",
      "decimals": "12",
      "location":
          "05010200711f06045041524100000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "42259045809535163221576417993425387648",
      "name": "xcDOT",
      "symbol": "xcDOT",
      "decimals": "10",
      "location": "050100"
    },
    {
      "asset_id": "45647473099451451833602657905356404688",
      "name": "Pendulum",
      "symbol": "xcPEN",
      "decimals": "12",
      "location": "05010200b920040a"
    },
    {
      "asset_id": "224821240862170613278369189818311486111",
      "name": "Acala",
      "symbol": "xcACA",
      "decimals": "12",
      "location":
          "05010200411f06020000000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "272547899416482196831721420898811311297",
      "name": "Bifrost Voucher FIL",
      "symbol": "xcvFIL",
      "decimals": "18",
      "location":
          "05010200b91f06020904000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "114018676402354620972806895487280206446",
      "name": "Bifrost Voucher ASTR",
      "symbol": "xcvASTR",
      "decimals": "18",
      "location":
          "05010200b91f06020903000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "233896737710358964064857020859081821253",
      "name": "Snowbridge ETH",
      "symbol": "ETH.e",
      "decimals": "18",
      "location": "050201090704"
    },
    {
      "asset_id": "238111524681612888331172110363070489924",
      "name": "NeuroWeb",
      "symbol": "xcNEURO",
      "decimals": "12",
      "location": "05010200ed1f040a"
    },
    {
      "asset_id": "112679793397406599376365943185137098326",
      "name": "STINK",
      "symbol": "xcSTINK",
      "decimals": "10",
      "location": "05010300a10f04320556910200"
    },
    {
      "asset_id": "132685552157663328694213725410064821485",
      "name": "Phala Token",
      "symbol": "xcPHA",
      "decimals": "12",
      "location": "05010100cd1f"
    },
    {
      "asset_id": "164507627753062513353393042023152019483",
      "name": "Snowbridge USDT",
      "symbol": "USDT.e",
      "decimals": "6",
      "location": "0502020907040300dac17f958d2ee523a2206206994597c13d831ec7"
    }
  ];

  static const List<Map<String, dynamic>> _moonBaseAssets = [
    {
      "asset_id": "108457044225666871745333730479173774551",
      "name": "Crust Shadow Native Token",
      "symbol": "xcCSM",
      "decimals": "12",
      "location": "05010100711f"
    },
    {
      "asset_id": "16797826370226091782818345603793389938",
      "name": "Astar",
      "symbol": "xcASTR",
      "decimals": "18",
      "location": "050101005d1f"
    },
    {
      "asset_id": "93566474319670817904055415639637167173",
      "name": "Butter",
      "symbol": "xcBTR",
      "decimals": "18",
      "location": "05010300a50f043205e514"
    },
    {
      "asset_id": "76100021443485661246318545281171740067",
      "name": "HKO",
      "symbol": "xcHKO",
      "decimals": "12",
      "location":
          "0501020095200603484b4f0000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "244316754493307480955066032215622931381",
      "name": "Picasso Cosmos Hub",
      "symbol": "xcPicaATOM",
      "decimals": "6",
      "location": "050103008d1f043a051c"
    },
    {
      "asset_id": "62171815555800780292345782481836202130",
      "name": "Polkadex Test Token",
      "symbol": "xcPDEX",
      "decimals": "12",
      "location": "050101007921"
    },
    {
      "asset_id": "22417088946346045371238623691600461855",
      "name": "Picasso",
      "symbol": "xcPICA",
      "decimals": "12",
      "location": "050101008d1f"
    },
    {
      "asset_id": "138512078356357941985706694377215053953",
      "name": "Tinker",
      "symbol": "xcTNKR",
      "decimals": "12",
      "location": "0501020035210500"
    },
    {
      "asset_id": "90225766094594282577230355136633846906",
      "name": "Polkadex Test Token",
      "symbol": "xcPDEX",
      "decimals": "12",
      "location": "05010100e11f"
    },
    {
      "asset_id": "280024949790879322861822169150106601773",
      "name": "xcMockRMRK",
      "symbol": "xcmRMRK",
      "decimals": "10",
      "location": "05010300a50f04320504"
    },
    {
      "asset_id": "144012926827374458669278577633504620722",
      "name": "Bifrost Filecoin Network Token",
      "symbol": "xcFIL",
      "decimals": "18",
      "location":
          "05010200b91f06020804000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "66249247788835743307843320271452141931",
      "name": "Bifrost Voucher BNC",
      "symbol": "xcvBNC",
      "decimals": "12",
      "location":
          "05010200b91f06020101000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "108036400430056508975016746969135344601",
      "name": "XRT",
      "symbol": "xcXRT",
      "decimals": "9",
      "location": "050101000120"
    },
    {
      "asset_id": "91372035960551235635465443179559840483",
      "name": "Centrifuge",
      "symbol": "xcCFG",
      "decimals": "18",
      "location":
          "05010200bd1f06020001000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "133300872918374599700079037156071917454",
      "name": "Turing Network",
      "symbol": "xcTUR",
      "decimals": "10",
      "location": "050101000921"
    },
    {
      "asset_id": "187224307232923873519830480073807488153",
      "name": "Equilibrium Dollar",
      "symbol": "xcEQD",
      "decimals": "9",
      "location":
          "050102006d1f06036571640000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "69606720909260275826784788104880799692",
      "name": "HydraDX",
      "symbol": "xcHDX",
      "decimals": "12",
      "location": "05010200c91f0500"
    },
    {
      "asset_id": "128910205779035707777113095265150484699",
      "name": "Nodle",
      "symbol": "xcNODL",
      "decimals": "11",
      "location": "05010200d11f0402"
    },
    {
      "asset_id": "337673893687553151312436182236099273778",
      "name": "MangataX",
      "symbol": "xcMGX",
      "decimals": "18",
      "location":
          "05010200f92006040000000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "190590555344745888270686124937537713878",
      "name": "Equilibrium Token",
      "symbol": "xcEQ",
      "decimals": "9",
      "location": "050101006d1f"
    },
    {
      "asset_id": "8812816049497534070792537960559175726",
      "name": "LAOS Alphanet",
      "symbol": "xcMAOS",
      "decimals": "18",
      "location": "05010100853e"
    },
    {
      "asset_id": "65216491554813189869575508812319036608",
      "name": "Litentry",
      "symbol": "xcLIT",
      "decimals": "12",
      "location": "05010200e920040a"
    },
    {
      "asset_id": "156305701417244550631956600137082963628",
      "name": "xcTestToken1",
      "symbol": "xcTT1",
      "decimals": "18",
      "location": "05010300a50f04320508"
    },
    {
      "asset_id": "173481220575862801646329923366065693029",
      "name": "Pangolin Alpha Network Native Token",
      "symbol": "xcPARING",
      "decimals": "18",
      "location": "05010200e5200405"
    },
    {
      "asset_id": "189307976387032586987344677431204943363",
      "name": "PHA",
      "symbol": "xcPHA",
      "decimals": "12",
      "location": "05010100511f"
    },
    {
      "asset_id": "264344629840762281112027368930249420542",
      "name": "Voucher KSM",
      "symbol": "xcvKSM",
      "decimals": "12",
      "location":
          "05010200451f06020104000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "255809804329513816629144221493516966233",
      "name": "Polkadex Token",
      "symbol": "xcPDEX",
      "decimals": "12",
      "location": "050101007121"
    },
    {
      "asset_id": "69536036667157951501899290870203586130",
      "name": "xcAlphaUniqueQuartz",
      "symbol": "xcAUQ",
      "decimals": "18",
      "location": "05010100bd20"
    },
    {
      "asset_id": "131139301019163526510593524852905318253",
      "name": "Bifrost Polkadot",
      "symbol": "xcBNC",
      "decimals": "12",
      "location":
          "05010200b91f06020001000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "56557508561302779576079054873115361688",
      "name": "Zeitgeist",
      "symbol": "ZTG",
      "decimals": "10",
      "location":
          "05010200d52006020001000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "306639095083798603270835754515874921389",
      "name": "BIT",
      "symbol": "xcBIT",
      "decimals": "18",
      "location":
          "05010200c12006090200000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "142155548796783636521833385094843759961",
      "name": "bncs-20 inscription token BNCS",
      "symbol": "xcBNCS",
      "decimals": "12",
      "location":
          "05010200b91f06020809000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "214920334981412447805621250067209749032",
      "name": "xcKarura-Dollar",
      "symbol": "xcKUSD",
      "decimals": "12",
      "location":
          "05010200411f06020081000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "123450836468524163052361263379051220337",
      "name": "Curio Governance Token",
      "symbol": "xcCGT",
      "decimals": "18",
      "location": "050101002d34"
    },
    {
      "asset_id": "565025040449484090264950386168462197",
      "name": "BNC",
      "symbol": "xcBNC",
      "decimals": "12",
      "location":
          "05010200451f06020001000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "224877400908528378831950189349919125668",
      "name": "Test USD",
      "symbol": "xcTUSD",
      "decimals": "6",
      "location": "05010300a50f0432059101"
    },
    {
      "asset_id": "105075627293246237499203909093923548958",
      "name": "TEER",
      "symbol": "xcTEER",
      "decimals": "12",
      "location":
          "050102007d1f06045445455200000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "204507659831918931608354793288110796652",
      "name": "Bifrost Voucher Glimmer",
      "symbol": "xcvGLMR",
      "decimals": "18",
      "location":
          "05010200b91f06020901000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "52280927600883288560727505734200597597",
      "name": "NEER",
      "symbol": "xcNEER",
      "decimals": "18",
      "location":
          "05010200c12006090000000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "205153165378836428058230526014907639736",
      "name": "Subsocial Cross-chain Token",
      "symbol": "xcSOON",
      "decimals": "10",
      "location": "05010100d120"
    },
    {
      "asset_id": "289989900872525819559124583375550296953",
      "name": "Bifrost Voucher MANTA",
      "symbol": "vMANTA",
      "decimals": "18",
      "location":
          "05010200b91f06020908000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "35487752324713722007834302681851459189",
      "name": "xcBETADEV",
      "symbol": "BetaDev",
      "decimals": "18",
      "location": "05010200e10d0403"
    },
    {
      "asset_id": "170050401128744171791743427490841452054",
      "name": "Amplitude",
      "symbol": "xcAMPE",
      "decimals": "12",
      "location": "050102003121040a"
    },
    {
      "asset_id": "113757166108095571031373835444145329310",
      "name": "xcLiquid-KSM",
      "symbol": "xcLKSM",
      "decimals": "12",
      "location":
          "05010200411f06020083000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "166446646689194205559791995948102903873",
      "name": "Manta Token",
      "symbol": "xcMANTA",
      "decimals": "18",
      "location": "05010100e120"
    },
    {
      "asset_id": "12009972993464827654650227422635011273",
      "name": "Interlay",
      "symbol": "xcINTR",
      "decimals": "10",
      "location":
          "05010200c11f06020002000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "54799287759721089563242211737206786491",
      "name": "xcGenshiro",
      "symbol": "xcGENS",
      "decimals": "9",
      "location": "05010100a11f"
    },
    {
      "asset_id": "102433417954722588084020852587557555194",
      "name": "Basilisk",
      "symbol": "xcBSX",
      "decimals": "12",
      "location":
          "05010200a92006040000000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "42259045809535163221576417993425387648",
      "name": "xcUNIT",
      "symbol": "xcUNIT",
      "decimals": "12",
      "location": "050100"
    },
    {
      "asset_id": "272547899416482196831721420898811311297",
      "name": "Bifrost Voucher Filecoin",
      "symbol": "xcvFIL",
      "decimals": "18",
      "location":
          "05010200b91f06020904000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "10810581592933651521121702237638664357",
      "name": "xcKarura",
      "symbol": "xcKAR",
      "decimals": "12",
      "location":
          "05010200411f06020080000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "52837329483626033197882584414163773570",
      "name": "xcKintsugi",
      "symbol": "XCKINT",
      "decimals": "12",
      "location":
          "05010200a90f0602000c000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "114018676402354620972806895487280206446",
      "name": "Bifrost Voucher ASTR",
      "symbol": "vASTR",
      "decimals": "18",
      "location":
          "05010200b91f06020903000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "311268264572112097121297553553681143695",
      "name": "SORA",
      "symbol": "xcXOR",
      "decimals": "18",
      "location":
          "050102006d1f06200200000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "122531866982275221270783173426160033062",
      "name": "Kintsugi Wrapped BTC",
      "symbol": "xcKBTC",
      "decimals": "8",
      "location":
          "05010200a90f0602000b000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "43334822478192663701103039265086012377",
      "name": "xcSubsquidToken",
      "symbol": "xcSQD",
      "decimals": "2",
      "location": "05010300a50f0432050c"
    },
    {
      "asset_id": "246731721631919099516624243100078522143",
      "name": "ICZ",
      "symbol": "xcICZ",
      "decimals": "18",
      "location":
          "05010200591f06020000000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "238111524681612888331172110363070489924",
      "name": "OriginTrail Parachain Token",
      "symbol": "xcOTP",
      "decimals": "12",
      "location": "05010200ed1f040a"
    },
    {
      "asset_id": "75066649112131892397889252914026143264",
      "name": "Agung",
      "symbol": "xcAGNG",
      "decimals": "18",
      "location": "05010100152f"
    }
  ];

  static const List<Map<String, dynamic>> _moonRiverAssets = [
    {
      "asset_id": "108457044225666871745333730479173774551",
      "name": "Crust Shadow Native Token",
      "symbol": "xcCSM",
      "decimals": "12",
      "location": "05010100711f"
    },
    {
      "asset_id": "16797826370226091782818345603793389938",
      "name": "Shiden",
      "symbol": "xcSDN",
      "decimals": "18",
      "location": "050101005d1f"
    },
    {
      "asset_id": "76100021443485661246318545281171740067",
      "name": "HKO",
      "symbol": "xcHKO",
      "decimals": "12",
      "location":
          "0501020095200603484b4f0000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "264528715839624829046161791069655377682",
      "name": "Moonbeam Tether USD",
      "symbol": "xcUSDT.mb",
      "decimals": "6",
      "location":
          "050204090200511f046e0300ffffffffea09fb06d082fd1275cd48b191cbcd1d"
    },
    {
      "asset_id": "138512078356357941985706694377215053953",
      "name": "Tinkernet",
      "symbol": "xcTNKR",
      "decimals": "12",
      "location": "0501020035210500"
    },
    {
      "asset_id": "45305549634539991528356533909445161106",
      "name": "Moonbeam USD Coin",
      "symbol": "xcUSDC.mb",
      "decimals": "6",
      "location":
          "050204090200511f046e0300ffffffff7d2b0b761af01ca8e25242976ac0ad7d"
    },
    {
      "asset_id": "328179947973504579459046439826496046832",
      "name": "Kintsugi Wrapped BTC",
      "symbol": "xcKBTC",
      "decimals": "8",
      "location":
          "05010200b1200602000b000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "108036400430056508975016746969135344601",
      "name": "Robonomics Native Token",
      "symbol": "xcXRT",
      "decimals": "9",
      "location": "050101000120"
    },
    {
      "asset_id": "133300872918374599700079037156071917454",
      "name": "Turing Network",
      "symbol": "xcTUR",
      "decimals": "10",
      "location": "050101000921"
    },
    {
      "asset_id": "213357169630950964874127107356898319277",
      "name": "Calamari",
      "symbol": "xcKMA",
      "decimals": "12",
      "location": "050101009120"
    },
    {
      "asset_id": "34940389883188672429634411751708934740",
      "name": "Bridged GLMR",
      "symbol": "GLMR.mb",
      "decimals": "18",
      "location": "050203090200511f040a"
    },
    {
      "asset_id": "65216491554813189869575508812319036608",
      "name": "LIT",
      "symbol": "xcLIT",
      "decimals": "12",
      "location": "05010200e920040a"
    },
    {
      "asset_id": "173481220575862801646329923366065693029",
      "name": "Crab Parachain Token",
      "symbol": "xcCRAB",
      "decimals": "18",
      "location": "05010200e5200405"
    },
    {
      "asset_id": "189307976387032586987344677431204943363",
      "name": "Phala Token",
      "symbol": "xcPHA",
      "decimals": "12",
      "location": "05010100511f"
    },
    {
      "asset_id": "264344629840762281112027368930249420542",
      "name": "Bifrost Voucher KSM",
      "symbol": "xcvKSM",
      "decimals": "12",
      "location":
          "05010200451f06020104000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "72145018963825376852137222787619937732",
      "name": "Bifrost Voucher BNC",
      "symbol": "xcvBNC",
      "decimals": "12",
      "location":
          "05010200451f06020101000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "214920334981412447805621250067209749032",
      "name": "aSEED",
      "symbol": "xcaSeed",
      "decimals": "12",
      "location":
          "05010200411f06020081000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "210223998887087232417477484708341610477",
      "name": "Moonbeam USDC.wh",
      "symbol": "whUSDC.mb",
      "decimals": "6",
      "location":
          "050204090200511f046e0300931715fee2d06333043d11f658c8ce934ac61d0c"
    },
    {
      "asset_id": "175400718394635817552109270754364440562",
      "name": "Kintsugi Native Token",
      "symbol": "xcKINT",
      "decimals": "12",
      "location":
          "05010200b1200602000c000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "167283995827706324502761431814209211090",
      "name": "Picasso",
      "symbol": "xcPICA",
      "decimals": "12",
      "location": "050101009d20"
    },
    {
      "asset_id": "105075627293246237499203909093923548958",
      "name": "TEER",
      "symbol": "xcTEER",
      "decimals": "12",
      "location":
          "050102007d1f06045445455200000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "118095707745084482624853002839493125353",
      "name": "Mangata X Native Token",
      "symbol": "xcMGX",
      "decimals": "18",
      "location":
          "05010200f92006040000000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "203223821023327994093278529517083736593",
      "name": "Bifrost Voucher MOVR",
      "symbol": "xcvMOVR",
      "decimals": "18",
      "location":
          "05010200451f0602010a000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "311091173110107856861649819128533077277",
      "name": "Tether USD",
      "symbol": "xcUSDT",
      "decimals": "6",
      "location": "05010300a10f043205011f"
    },
    {
      "asset_id": "182365888117048807484804376330534607370",
      "name": "xcRMRK",
      "symbol": "xcRMRK",
      "decimals": "10",
      "location": "05010300a10f04320520"
    },
    {
      "asset_id": "42259045809535163221576417993425387648",
      "name": "xcKSM",
      "symbol": "xcKSM",
      "decimals": "12",
      "location": "050100"
    },
    {
      "asset_id": "10810581592933651521121702237638664357",
      "name": "Karura",
      "symbol": "xcKAR",
      "decimals": "12",
      "location":
          "05010200411f06020080000000000000000000000000000000000000000000000000000000000000"
    },
    {
      "asset_id": "319623561105283008236062145480775032445",
      "name": "xcBNC",
      "symbol": "xcBNC",
      "decimals": "12",
      "location":
          "05010200451f06020001000000000000000000000000000000000000000000000000000000000000"
    }
  ];

  ////
}
