# OTRS config file (automatically generated)
# VERSION:1.1
package Kernel::Config::Files::ZZZProcessManagement;
use strict;
use warnings;
no warnings 'redefine'; ## no critic
use utf8;
sub Load {
    my ($File, $Self) = @_;
$Self->{'Process'} = {
  'Process-01e981d5d7223fb6aaa55a5dbd4a1d1b' => {
    'ChangeTime' => '2021-12-15 13:46:16',
    'CreateTime' => '2021-10-13 11:20:02',
    'Name' => 'Chamado Reclamações GR',
    'Path' => {
      'Activity-8a3aa42ee42a35234ffdbcc36f64672b' => {},
      'Activity-d58285c33ee48d240f0682dc7815e790' => {
        'Transition-0d3ed37b5a7a415c46d486a1a2edbf2a' => {
          'ActivityEntityID' => 'Activity-8a3aa42ee42a35234ffdbcc36f64672b',
          'TransitionAction' => [
            'TransitionAction-e015aa70d43655427894c238f68378ab',
            'TransitionAction-7ae0c3bb0a4ecce9f35d5ef3b33a314d',
            'TransitionAction-60f9f493d562ed11422e6e46a3ae4eb5'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-d58285c33ee48d240f0682dc7815e790',
    'StartActivityDialog' => 'ActivityDialog-b34a7aec6ff861effc4c8cb228afce9c',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-02f4ecb1397d6dc35826527c83b9f199' => {
    'ChangeTime' => '2026-08-17 09:15:04',
    'CreateTime' => '2021-01-11 15:15:17',
    'Name' => 'Chamado Frete Bloqueado',
    'Path' => {
      'Activity-14c45316dff58941c558a0f31cbdadd5' => {
        'Transition-9732d59bce43b339eb81e4870f12f061' => {
          'ActivityEntityID' => 'Activity-d3b95b39c07d64176b57f5e03bb0079b',
          'TransitionAction' => [
            'TransitionAction-ef11e06905bcb3ceb65cfb54306121d8'
          ]
        },
        'Transition-e6aa5f5588a66dbebd492d8b3be5bc53' => {
          'ActivityEntityID' => 'Activity-547158582bb4b4e2e0ad3b44b2d33d06',
          'TransitionAction' => [
            'TransitionAction-cd8bda1518d5a1b9036b1324affedb76'
          ]
        }
      },
      'Activity-547158582bb4b4e2e0ad3b44b2d33d06' => {
        'Transition-38ba95ab67fdff823560f3dc546eea61' => {
          'ActivityEntityID' => 'Activity-959b3c18bb5898f528eb91a9df1e167a',
          'TransitionAction' => [
            'TransitionAction-ef11e06905bcb3ceb65cfb54306121d8'
          ]
        }
      },
      'Activity-7bd458a3ea9d37b3372a947727d5495f' => {
        'Transition-3e5afc39e3984a1074a7dcf6afdbb6de' => {
          'ActivityEntityID' => 'Activity-547158582bb4b4e2e0ad3b44b2d33d06',
          'TransitionAction' => [
            'TransitionAction-cd8bda1518d5a1b9036b1324affedb76',
            'TransitionAction-675c0fa85a10528965a10b1641d01271'
          ]
        },
        'Transition-f6dcf6d1b326a7f5df2f27fca16d89da' => {
          'ActivityEntityID' => 'Activity-14c45316dff58941c558a0f31cbdadd5',
          'TransitionAction' => [
            'TransitionAction-88d9974c46daaca24f268f4dc6ac9338',
            'TransitionAction-73b7a4d7f3493c06344e34dcd4d68bd6'
          ]
        }
      },
      'Activity-959b3c18bb5898f528eb91a9df1e167a' => {},
      'Activity-d3b95b39c07d64176b57f5e03bb0079b' => {}
    },
    'StartActivity' => 'Activity-7bd458a3ea9d37b3372a947727d5495f',
    'StartActivityDialog' => 'ActivityDialog-e7281b17803a9beb7008dbab2c213026',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-04ef82d7fef0194e6d9828c08f67e415' => {
    'ChangeTime' => '2023-07-13 08:33:03',
    'CreateTime' => '2023-05-15 09:38:02',
    'Name' => 'Importação MultiCTE',
    'Path' => {
      'Activity-21cdcdf873c446c61062270e916f0a77' => {
        'Transition-9dd853056049520501b0ec71358b4a42' => {
          'ActivityEntityID' => 'Activity-299e3ba71d6faa1adeeaff062661d5b2',
          'TransitionAction' => [
            'TransitionAction-0232f81838d66c381da6bb2dd84271dc'
          ]
        }
      },
      'Activity-299e3ba71d6faa1adeeaff062661d5b2' => {}
    },
    'StartActivity' => 'Activity-21cdcdf873c446c61062270e916f0a77',
    'StartActivityDialog' => 'ActivityDialog-40ce57d51211544087e15b525e5be531',
    'State' => 'Inactive',
    'StateEntityID' => 'S2'
  },
  'Process-15c755cc46c01474d65eb1784d78b57b' => {
    'ChangeTime' => '2023-10-27 17:07:31',
    'CreateTime' => '2022-07-26 09:42:53',
    'Name' => 'Reembolso de Despesa Conselheiros',
    'Path' => {
      'Activity-0afcf95ae9300cf50db74bc032ecdaac' => {},
      'Activity-c291bd8263ea54f847191586f719c203' => {
        'Transition-fbfe21997a1fae4f3b20af3e7e77a219' => {
          'ActivityEntityID' => 'Activity-0afcf95ae9300cf50db74bc032ecdaac',
          'TransitionAction' => [
            'TransitionAction-e6a3a3823ddbbec12e54389c12a0f003'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-c291bd8263ea54f847191586f719c203',
    'StartActivityDialog' => 'ActivityDialog-67c537a7243273883f729c09383753a4',
    'State' => 'Inactive',
    'StateEntityID' => 'S2'
  },
  'Process-198b722122c1cbbf4a63f6f62a29c695' => {
    'ChangeTime' => '2021-12-15 13:46:38',
    'CreateTime' => '2021-06-10 09:49:25',
    'Name' => 'Chamado Voz do Cooperado',
    'Path' => {
      'Activity-67dc497ded44a2f5aa4b5ff09d4fe1eb' => {
        'Transition-67380647ee020f9a24e398a291b12cdd' => {
          'ActivityEntityID' => 'Activity-f65111eb6ee17a37b40d4b2880265e9d',
          'TransitionAction' => [
            'TransitionAction-1b4a33ad97033c50b2430e3e5834fa66',
            'TransitionAction-73f57ad4b0f45b971c0b985e2a43b141',
            'TransitionAction-ce6c28a8ce05d632d33168f38c5488f1'
          ]
        }
      },
      'Activity-f65111eb6ee17a37b40d4b2880265e9d' => {}
    },
    'StartActivity' => 'Activity-67dc497ded44a2f5aa4b5ff09d4fe1eb',
    'StartActivityDialog' => 'ActivityDialog-be5ea986d951a966f0317882df049e6b',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-1f40e1ba7930aca8e4b6cc37aebeae8b' => {
    'ChangeTime' => '2021-12-15 13:45:33',
    'CreateTime' => '2021-04-08 10:37:40',
    'Name' => 'Chamado Pesquisa Nova Carreta',
    'Path' => {
      'Activity-219363c9f804d2ed2ac5658712a66d5b' => {
        'Transition-607607e2d64c1f941dd0ccc45fa944d8' => {
          'ActivityEntityID' => 'Activity-fa2f8654fa5ed3e35ca689feddb4d93a',
          'TransitionAction' => [
            'TransitionAction-fc27eb0b696b7e7d646f0ca3c7864cf8',
            'TransitionAction-e16d48a9a3906cb66e878764ef4847bc'
          ]
        }
      },
      'Activity-fa2f8654fa5ed3e35ca689feddb4d93a' => {}
    },
    'StartActivity' => 'Activity-219363c9f804d2ed2ac5658712a66d5b',
    'StartActivityDialog' => 'ActivityDialog-7ed7a50997e7643835f144e89bb91e27',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-217d3e9969ace767f68eaf779a4908c2' => {
    'ChangeTime' => '2022-10-10 13:51:32',
    'CreateTime' => '2022-07-27 15:30:11',
    'Name' => 'Cadastro de Motorista',
    'Path' => {
      'Activity-5db1fff06b36ff1d4f63426c1012e7fe' => {
        'Transition-0491e5279ec69e5fd58521b38287d375' => {
          'ActivityEntityID' => 'Activity-e6b5f3828e4455c577f2fa7da9576c91',
          'TransitionAction' => [
            'TransitionAction-e42829e03eb6793412051227265cb507'
          ]
        }
      },
      'Activity-e6b5f3828e4455c577f2fa7da9576c91' => {}
    },
    'StartActivity' => 'Activity-5db1fff06b36ff1d4f63426c1012e7fe',
    'StartActivityDialog' => 'ActivityDialog-d60045da8a265ff06ffa8ea1d47e3d6e',
    'State' => 'Inactive',
    'StateEntityID' => 'S2'
  },
  'Process-29d7aad86f50e8197f56341c71c4bf90' => {
    'ChangeTime' => '2026-07-30 14:20:26',
    'CreateTime' => '2021-01-11 15:16:45',
    'Name' => 'Chamado Diária ao Descarregar',
    'Path' => {
      'Activity-3f2ae3a3d1f6ffd4db0bfd458b8f3372' => {},
      'Activity-6323b5250165b54849b0b203eaf8243a' => {
        'Transition-ab5d74c796f2ac79043f3083e5c18563' => {
          'ActivityEntityID' => 'Activity-3f2ae3a3d1f6ffd4db0bfd458b8f3372',
          'TransitionAction' => [
            'TransitionAction-68334a2ce8bd1e85c1fdc9d42828d927'
          ]
        }
      },
      'Activity-918256d4a60fb50d325de3bea9b13444' => {},
      'Activity-e2a00fa5a6f60667b8a82fc4e2921bab' => {
        'Transition-3e5afc39e3984a1074a7dcf6afdbb6de' => {
          'ActivityEntityID' => 'Activity-6323b5250165b54849b0b203eaf8243a',
          'TransitionAction' => [
            'TransitionAction-5e90e23e1c8bcbf147445e881f6998f4',
            'TransitionAction-2209c0ce263f8ccdcca62c24d9e6adb4',
            'TransitionAction-675c0fa85a10528965a10b1641d01271'
          ]
        },
        'Transition-bb4e1bf45c1fbf0374c300c5860c23ef' => {
          'ActivityEntityID' => 'Activity-f7b946de4dd979529ad56ebff67322b1',
          'TransitionAction' => [
            'TransitionAction-e71b81ccf4892ad2d8d0738123ca2c75',
            'TransitionAction-2209c0ce263f8ccdcca62c24d9e6adb4',
            'TransitionAction-675c0fa85a10528965a10b1641d01271'
          ]
        }
      },
      'Activity-f7b946de4dd979529ad56ebff67322b1' => {
        'Transition-64b16c29eefa8abf728bfa9e67bc3d3a' => {
          'ActivityEntityID' => 'Activity-6323b5250165b54849b0b203eaf8243a',
          'TransitionAction' => [
            'TransitionAction-5e90e23e1c8bcbf147445e881f6998f4',
            'TransitionAction-92104974a45f61168b75e46d5ff1fcd7'
          ]
        },
        'Transition-798d99f794296ec6a27c8cb8fb17929a' => {
          'ActivityEntityID' => 'Activity-918256d4a60fb50d325de3bea9b13444',
          'TransitionAction' => [
            'TransitionAction-68334a2ce8bd1e85c1fdc9d42828d927'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-e2a00fa5a6f60667b8a82fc4e2921bab',
    'StartActivityDialog' => 'ActivityDialog-b3ab90b93dfe94a87d5bfdeffc3cec0c',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-3323adf53b25c6e55f9163a2ea0df6d1' => {
    'ChangeTime' => '2023-07-03 14:35:24',
    'CreateTime' => '2021-03-25 17:25:17',
    'Name' => 'Chamado Reembolso de Imposto Fiscal',
    'Path' => {
      'Activity-0c873649c514c33bb401e0053fe8d952' => {},
      'Activity-220f464cfe897fc89baf93f8fc54f460' => {
        'Transition-ab5d74c796f2ac79043f3083e5c18563' => {
          'ActivityEntityID' => 'Activity-0c873649c514c33bb401e0053fe8d952'
        }
      },
      'Activity-cd18fec13f3f836de9b2d48b1d776fb5' => {
        'Transition-5d63750e105ca2b7400da9ac4ff1b951' => {
          'ActivityEntityID' => 'Activity-220f464cfe897fc89baf93f8fc54f460',
          'TransitionAction' => [
            'TransitionAction-5e90e23e1c8bcbf147445e881f6998f4',
            'TransitionAction-9193a934b4bad0bce8c02912cdbd6977',
            'TransitionAction-675c0fa85a10528965a10b1641d01271'
          ]
        },
        'Transition-bb4e1bf45c1fbf0374c300c5860c23ef' => {
          'ActivityEntityID' => 'Activity-d0c051bf20525a823503926d19151257',
          'TransitionAction' => [
            'TransitionAction-e71b81ccf4892ad2d8d0738123ca2c75',
            'TransitionAction-9193a934b4bad0bce8c02912cdbd6977',
            'TransitionAction-7e0f5be36f8a2bcbc4694e51b4f36d47'
          ]
        }
      },
      'Activity-d0c051bf20525a823503926d19151257' => {}
    },
    'StartActivity' => 'Activity-cd18fec13f3f836de9b2d48b1d776fb5',
    'StartActivityDialog' => 'ActivityDialog-cfd3c4cf72e1ad07a82ab83b5c84a46c',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-3441cae82722c15b887a3b1a3b8614db' => {
    'ChangeTime' => '2022-01-12 10:41:24',
    'CreateTime' => '2020-11-19 14:56:55',
    'Name' => 'Fluxo Comercial Contratos - Inativo',
    'Path' => {},
    'StartActivity' => '',
    'StartActivityDialog' => '',
    'State' => 'Inactive',
    'StateEntityID' => 'S2'
  },
  'Process-3b50b1fa289e884fd847a6dc707f6c15' => {
    'ChangeTime' => '2025-12-17 08:53:50',
    'CreateTime' => '2025-12-11 11:26:33',
    'Name' => 'NewKMM',
    'Path' => {
      'Activity-018267f67c66cfcfaba3203ea6bc3430' => {},
      'Activity-9b2083c9a35d2039bdae4854eabdc504' => {
        'Transition-de296610d52445cc0ba31ee00289a277' => {
          'ActivityEntityID' => 'Activity-018267f67c66cfcfaba3203ea6bc3430',
          'TransitionAction' => [
            'TransitionAction-7eb0b4a89e9484287fbcde07d352d9ae'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-9b2083c9a35d2039bdae4854eabdc504',
    'StartActivityDialog' => 'ActivityDialog-1dfdf2ace7d56ac9de1a8c281b309a7a',
    'State' => 'Inactive',
    'StateEntityID' => 'S2'
  },
  'Process-40a1558d420ba1e4da5cdf7a043ec5ff' => {
    'ChangeTime' => '2026-01-20 10:50:33',
    'CreateTime' => '2026-01-20 10:50:33',
    'Name' => 'Chamado de Diária',
    'Path' => {},
    'StartActivity' => '',
    'StartActivityDialog' => '',
    'State' => 'Inactive',
    'StateEntityID' => 'S2'
  },
  'Process-414a68f941ab2def6682afc9d8bd8754' => {
    'ChangeTime' => '2022-02-21 17:55:09',
    'CreateTime' => '2022-02-21 17:02:51',
    'Name' => 'Chamado para Cancelamentos LCD/Contrato/Extrato',
    'Path' => {
      'Activity-53bf5ebd6f7d1cbfc10f2aee42106595' => {
        'Transition-3e5afc39e3984a1074a7dcf6afdbb6de' => {
          'ActivityEntityID' => 'Activity-6323b5250165b54849b0b203eaf8243a'
        }
      },
      'Activity-6323b5250165b54849b0b203eaf8243a' => {}
    },
    'StartActivity' => 'Activity-53bf5ebd6f7d1cbfc10f2aee42106595',
    'StartActivityDialog' => '',
    'State' => 'Inactive',
    'StateEntityID' => 'S2'
  },
  'Process-42ae0a24bff5de558dfd01d86fe7caec' => {
    'ChangeTime' => '2022-01-31 16:43:23',
    'CreateTime' => '2019-02-07 17:18:59',
    'Name' => 'Anulacao',
    'Path' => {
      'Activity-96b7da049154684f7619faa15a9ee601' => {}
    },
    'StartActivity' => 'Activity-96b7da049154684f7619faa15a9ee601',
    'StartActivityDialog' => 'ActivityDialog-2bdd6cd256170f7fabf8137b87e61217',
    'State' => 'Inactive',
    'StateEntityID' => 'S2'
  },
  'Process-44d202e505fce9226517f2426817fba9' => {
    'ChangeTime' => '2021-12-15 13:45:11',
    'CreateTime' => '2021-07-01 14:58:50',
    'Name' => 'Chamado Liberação Treinamento',
    'Path' => {
      'Activity-2c86d83e9301510b80753f5d5ecf635d' => {},
      'Activity-e39170cdc2dcc99383d790aad44cf2f7' => {
        'Transition-2c2ef8468014d00cb8db8ded422cf515' => {
          'ActivityEntityID' => 'Activity-2c86d83e9301510b80753f5d5ecf635d',
          'TransitionAction' => [
            'TransitionAction-b2e7d205e1dd516fbd6eeb0c918cbe88',
            'TransitionAction-d6ec2848928ec639ea8ad2df976b313f',
            'TransitionAction-3c62aa9a98549e3d621e211d8e9a0709'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-e39170cdc2dcc99383d790aad44cf2f7',
    'StartActivityDialog' => 'ActivityDialog-cbbc560d0b7e9c5300109afc16edd094',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-4865ab1fa273ba0fbaa7b64e2ef74b3b' => {
    'ChangeTime' => '2021-12-15 13:46:31',
    'CreateTime' => '2021-10-20 10:20:19',
    'Name' => 'Chamado Retirada de Veículo da Frota',
    'Path' => {
      'Activity-39da1ccd84d5000b7e4b1e59056514d6' => {
        'Transition-ad03af1c27cf330fe8c1dec2a8718f69' => {
          'ActivityEntityID' => 'Activity-cefe5df7baa4c1a9c6334a3112163dc6',
          'TransitionAction' => [
            'TransitionAction-b4684b7534ceb38dcf6ef0005a233259',
            'TransitionAction-29a034d21e8b87ea76a045840044c88a',
            'TransitionAction-3610c9f0392ce7af5506c2ec19fdecc6'
          ]
        }
      },
      'Activity-cefe5df7baa4c1a9c6334a3112163dc6' => {}
    },
    'StartActivity' => 'Activity-39da1ccd84d5000b7e4b1e59056514d6',
    'StartActivityDialog' => 'ActivityDialog-fa86248da41a0fed937e7ecdac5c2db2',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-4b491ffe20345a28e32555c19f993a7d' => {
    'ChangeTime' => '2023-11-13 09:34:02',
    'CreateTime' => '2021-01-11 15:15:43',
    'Name' => 'Chamado Divergência Valor de Frete',
    'Path' => {
      'Activity-4f96554da48afd4191ce07aee15e83cf' => {},
      'Activity-8404e6b49a5b79a00d05e5c1a9eb3bc6' => {},
      'Activity-cc846a75b91f3ed31d2291d629dd5a45' => {
        'Transition-9732d59bce43b339eb81e4870f12f061' => {
          'ActivityEntityID' => 'Activity-4f96554da48afd4191ce07aee15e83cf',
          'TransitionAction' => [
            'TransitionAction-ef11e06905bcb3ceb65cfb54306121d8'
          ]
        },
        'Transition-e6aa5f5588a66dbebd492d8b3be5bc53' => {
          'ActivityEntityID' => 'Activity-d71a903a9c6dc8a9e52c223bf9b0362f',
          'TransitionAction' => [
            'TransitionAction-cd8bda1518d5a1b9036b1324affedb76'
          ]
        }
      },
      'Activity-d71a903a9c6dc8a9e52c223bf9b0362f' => {
        'Transition-38ba95ab67fdff823560f3dc546eea61' => {
          'ActivityEntityID' => 'Activity-8404e6b49a5b79a00d05e5c1a9eb3bc6',
          'TransitionAction' => [
            'TransitionAction-ef11e06905bcb3ceb65cfb54306121d8'
          ]
        }
      },
      'Activity-e48af2fade008319bbb0319009a088ef' => {
        'Transition-3e5afc39e3984a1074a7dcf6afdbb6de' => {
          'ActivityEntityID' => 'Activity-d71a903a9c6dc8a9e52c223bf9b0362f',
          'TransitionAction' => [
            'TransitionAction-32ae8266aed03f86eda026045d026d94',
            'TransitionAction-675c0fa85a10528965a10b1641d01271'
          ]
        },
        'Transition-f6dcf6d1b326a7f5df2f27fca16d89da' => {
          'ActivityEntityID' => 'Activity-cc846a75b91f3ed31d2291d629dd5a45',
          'TransitionAction' => [
            'TransitionAction-88d9974c46daaca24f268f4dc6ac9338',
            'TransitionAction-dad70f041efe7ca0094df405f159afea'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-e48af2fade008319bbb0319009a088ef',
    'StartActivityDialog' => 'ActivityDialog-dc48d1afd0dbd7e535dcd41b26d3a29e',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-56ca5a2f78e80b672d746c80e1ef0e95' => {
    'ChangeTime' => '2026-10-14 13:10:09',
    'CreateTime' => '2026-10-14 13:10:09',
    'Name' => 'Chamado Diaria No Carregamento',
    'Path' => {
      'Activity-1f1f75e95d2b2f93b235e00b66636c36' => {
        'Transition-3e5afc39e3984a1074a7dcf6afdbb6de' => {
          'ActivityEntityID' => 'Activity-faf71b8f1a4c0e8b18e88ea0333c2053',
          'TransitionAction' => [
            'TransitionAction-cd8bda1518d5a1b9036b1324affedb76',
            'TransitionAction-64992ddef1ce1debfb1c59fd067b801e'
          ]
        },
        'Transition-f6dcf6d1b326a7f5df2f27fca16d89da' => {
          'ActivityEntityID' => 'Activity-5ef3278b98f1efdc55e2a44327952ae1',
          'TransitionAction' => [
            'TransitionAction-e71b81ccf4892ad2d8d0738123ca2c75',
            'TransitionAction-91abd1dde98e9edd5cd261862fb6d954',
            'TransitionAction-64992ddef1ce1debfb1c59fd067b801e'
          ]
        }
      },
      'Activity-4096f787f5f1918247436ffc7924ef19' => {},
      'Activity-5ef3278b98f1efdc55e2a44327952ae1' => {
        'Transition-9732d59bce43b339eb81e4870f12f061' => {
          'ActivityEntityID' => 'Activity-9f2eb55cdc07c63039c211ec2fc36749',
          'TransitionAction' => [
            'TransitionAction-ef11e06905bcb3ceb65cfb54306121d8'
          ]
        },
        'Transition-e6aa5f5588a66dbebd492d8b3be5bc53' => {
          'ActivityEntityID' => 'Activity-faf71b8f1a4c0e8b18e88ea0333c2053',
          'TransitionAction' => [
            'TransitionAction-cd8bda1518d5a1b9036b1324affedb76'
          ]
        }
      },
      'Activity-9f2eb55cdc07c63039c211ec2fc36749' => {},
      'Activity-faf71b8f1a4c0e8b18e88ea0333c2053' => {
        'Transition-38ba95ab67fdff823560f3dc546eea61' => {
          'ActivityEntityID' => 'Activity-4096f787f5f1918247436ffc7924ef19',
          'TransitionAction' => [
            'TransitionAction-ef11e06905bcb3ceb65cfb54306121d8'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-1f1f75e95d2b2f93b235e00b66636c36',
    'StartActivityDialog' => 'ActivityDialog-a96ea4e798e67fe9c789f87b8968c048',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-629a4403306450035fc3a601e0a6a149' => {
    'ChangeTime' => '2021-12-15 13:45:04',
    'CreateTime' => '2021-04-08 08:32:06',
    'Name' => 'Chamado Informe de Rendimentos',
    'Path' => {
      'Activity-b0eb16c0fa3167181bdb76b88ab48c02' => {},
      'Activity-f23688bdc1a42c66cdd9adeed1f0261b' => {
        'Transition-3beef66bdb6d8b96028744300afa9f27' => {
          'ActivityEntityID' => 'Activity-b0eb16c0fa3167181bdb76b88ab48c02',
          'TransitionAction' => [
            'TransitionAction-ecd0c9019ae5305b30f586fda49dd3ce',
            'TransitionAction-71bb6b64de549fb494d5571905b40baf',
            'TransitionAction-312929a5a6f5e2e5a6cfacc3630e5646'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-f23688bdc1a42c66cdd9adeed1f0261b',
    'StartActivityDialog' => 'ActivityDialog-e9074d0d3c27bd3dade46066f219608c',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-646f00304cc7a849fb29520a71c85733' => {
    'ChangeTime' => '2023-07-12 08:49:16',
    'CreateTime' => '2021-01-11 15:17:38',
    'Name' => 'Chamado Recibo de Descarga',
    'Path' => {
      'Activity-29cf6d2c8f7e5b25830b8545cea7871d' => {},
      'Activity-37f9e0592597465dae385ee9aef2ec9d' => {
        'Transition-38ba95ab67fdff823560f3dc546eea61' => {
          'ActivityEntityID' => 'Activity-95744216ae3bc32970ce501097c47dad',
          'TransitionAction' => [
            'TransitionAction-ef11e06905bcb3ceb65cfb54306121d8'
          ]
        }
      },
      'Activity-76471f703e71c44e3d778fdbf897ae14' => {
        'Transition-3e5afc39e3984a1074a7dcf6afdbb6de' => {
          'ActivityEntityID' => 'Activity-37f9e0592597465dae385ee9aef2ec9d',
          'TransitionAction' => [
            'TransitionAction-cd8bda1518d5a1b9036b1324affedb76',
            'TransitionAction-675c0fa85a10528965a10b1641d01271',
            'TransitionAction-fd58762a794568d5724cb33aebca187c'
          ]
        },
        'Transition-f6dcf6d1b326a7f5df2f27fca16d89da' => {
          'ActivityEntityID' => 'Activity-c21b00a8ee10a1a38833f42cdd7d0966',
          'TransitionAction' => [
            'TransitionAction-e71b81ccf4892ad2d8d0738123ca2c75',
            'TransitionAction-17b92690a7f1793449fe9265ad47e06d',
            'TransitionAction-fd58762a794568d5724cb33aebca187c'
          ]
        }
      },
      'Activity-95744216ae3bc32970ce501097c47dad' => {},
      'Activity-c21b00a8ee10a1a38833f42cdd7d0966' => {
        'Transition-9732d59bce43b339eb81e4870f12f061' => {
          'ActivityEntityID' => 'Activity-29cf6d2c8f7e5b25830b8545cea7871d',
          'TransitionAction' => [
            'TransitionAction-ef11e06905bcb3ceb65cfb54306121d8'
          ]
        },
        'Transition-e6aa5f5588a66dbebd492d8b3be5bc53' => {
          'ActivityEntityID' => 'Activity-37f9e0592597465dae385ee9aef2ec9d',
          'TransitionAction' => [
            'TransitionAction-cd8bda1518d5a1b9036b1324affedb76'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-76471f703e71c44e3d778fdbf897ae14',
    'StartActivityDialog' => 'ActivityDialog-380e90623264f051b87cf8a72e538865',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-65ea47102f723f5359a2e6b3b9bdd3f6' => {
    'ChangeTime' => '2026-09-03 09:53:53',
    'CreateTime' => '2021-04-07 15:19:34',
    'Name' => 'Chamado Pesquisa Novo Cavalo',
    'Path' => {
      'Activity-ab79e7bfe06bfb286094b6b7985f85ca' => {
        'Transition-a3d7efafe0826c59cd1190e2aedda5e1' => {
          'ActivityEntityID' => 'Activity-ea91cf73f7134ddf0e098e811fe9a0a5',
          'TransitionAction' => [
            'TransitionAction-e6a3a3823ddbbec12e54389c12a0f003',
            'TransitionAction-aa2281aa9ca6f99710cc25cf43edba4f',
            'TransitionAction-591247449134751f03c3fe287bfc0822'
          ]
        }
      },
      'Activity-b0c8b5c31975d58c71aee3612e7e7ebf' => {},
      'Activity-ea91cf73f7134ddf0e098e811fe9a0a5' => {
        'Transition-80d179e7bf73c3ebd8107625843e3fa5' => {
          'ActivityEntityID' => 'Activity-b0c8b5c31975d58c71aee3612e7e7ebf',
          'TransitionAction' => [
            'TransitionAction-68334a2ce8bd1e85c1fdc9d42828d927'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-ab79e7bfe06bfb286094b6b7985f85ca',
    'StartActivityDialog' => 'ActivityDialog-5b65d9fa9f78d45eb21b49b1d6c0c1c4',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-6ae5ffa9e25e35174f1ef5ab2aaca119' => {
    'ChangeTime' => '2022-07-18 15:38:37',
    'CreateTime' => '2022-07-18 08:37:14',
    'Name' => 'Chamado Seguro de Vida',
    'Path' => {
      'Activity-0a66083031a392c083562b1c39238fd0' => {},
      'Activity-4a0ed13ff0fe702743fc559f1e120f39' => {
        'Transition-4e50936d9601c4ab72905ce71f3bffb3' => {
          'ActivityEntityID' => 'Activity-0a66083031a392c083562b1c39238fd0',
          'TransitionAction' => []
        }
      },
      'Activity-f278b2baadc7d88f1b206d3e6a60ef6e' => {
        'Transition-21e17ba120713942188b18d6eb66c8ce' => {
          'ActivityEntityID' => 'Activity-4a0ed13ff0fe702743fc559f1e120f39',
          'TransitionAction' => [
            'TransitionAction-b874c12595804684c36c4c861c724a1b',
            'TransitionAction-d205afacf57879d0b2e36d93dc9f83f9',
            'TransitionAction-874f9fdc07762f17daa5f677f14c4a94',
            'TransitionAction-e25af47cb62b3bca4a5fa7864ec01f5e',
            'TransitionAction-8b5fe68cc93169e4e947ef67bbf8b983'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-f278b2baadc7d88f1b206d3e6a60ef6e',
    'StartActivityDialog' => 'ActivityDialog-2de93fb09d400f1d8d30efdc23d96d82',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-7046c9a397811ca1ff87daf39f87a594' => {
    'ChangeTime' => '2021-12-15 13:45:19',
    'CreateTime' => '2021-04-08 09:22:40',
    'Name' => 'Chamado Outras Demandas',
    'Path' => {
      'Activity-1dd58f403708893091247acafcdf6f7b' => {},
      'Activity-203f464c776e853da6a585722ff458d5' => {
        'Transition-1ae1477e541a39a8c4d19aeecdcd87ce' => {
          'ActivityEntityID' => 'Activity-1dd58f403708893091247acafcdf6f7b',
          'TransitionAction' => [
            'TransitionAction-5f8115b756bb2362b9adb9bd34434b55'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-203f464c776e853da6a585722ff458d5',
    'StartActivityDialog' => 'ActivityDialog-22c0932c26758c593b257eda069bd35b',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-7caae57895528905892e83852a93eb43' => {
    'ChangeTime' => '2023-10-27 16:58:59',
    'CreateTime' => '2022-07-28 16:53:57',
    'Name' => 'Cadastro Florestal',
    'Path' => {
      'Activity-959f74348ab50f357234476d961ea201' => {},
      'Activity-9a7a81c4d2e7f7ea67d27b0bea5fbb0f' => {
        'Transition-0491e5279ec69e5fd58521b38287d375' => {
          'ActivityEntityID' => 'Activity-959f74348ab50f357234476d961ea201'
        }
      }
    },
    'StartActivity' => 'Activity-9a7a81c4d2e7f7ea67d27b0bea5fbb0f',
    'StartActivityDialog' => 'ActivityDialog-d60045da8a265ff06ffa8ea1d47e3d6e',
    'State' => 'Inactive',
    'StateEntityID' => 'S2'
  },
  'Process-9395e91e7188bf5f9ee66fee0a1a8b54' => {
    'ChangeTime' => '2026-07-28 09:54:03',
    'CreateTime' => '2026-07-28 09:37:06',
    'Name' => 'valor previsível da estadia',
    'Path' => {
      'Activity-bb60dff927a4068d3b4a6073f04a6ecd' => {}
    },
    'StartActivity' => 'Activity-bb60dff927a4068d3b4a6073f04a6ecd',
    'StartActivityDialog' => 'ActivityDialog-003f712ca1ec4d7465f438f279eed3d4',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-93d1d50abc0c949d7fe75ecbe27b9456' => {
    'ChangeTime' => '2022-01-12 10:41:44',
    'CreateTime' => '2021-11-26 14:00:34',
    'Name' => 'Chamado Pesquisa Novo Cavalo (Melhoria - Teste) - Inativo',
    'Path' => {
      'Activity-0f1ba4865b04ac860f4a775bb8f456aa' => {},
      'Activity-c3eadf55a512904663b20e95a8ac67f9' => {
        'Transition-20182db048c6a754b9dd2d11870ccdfb' => {
          'ActivityEntityID' => 'Activity-ca3c4aebe21d59621a4dc56edb2738e5',
          'TransitionAction' => [
            'TransitionAction-48e638cae1ce9e0dbc9705ee4126da26'
          ]
        }
      },
      'Activity-ca3c4aebe21d59621a4dc56edb2738e5' => {},
      'Activity-d476bf12e1684c6763210fe58ae86aac' => {
        'Transition-801482b55aaeb5e0098d76ac42d85cb9' => {
          'ActivityEntityID' => 'Activity-d6fd78907a8ce6a2d01e61ee6bb82439',
          'TransitionAction' => [
            'TransitionAction-cb5a26be1396a8bc4da22ab515bd8c9a',
            'TransitionAction-b1ffefe226fb466a528d0f2f2a3dc9a5',
            'TransitionAction-aa2281aa9ca6f99710cc25cf43edba4f',
            'TransitionAction-050e107607ce4157d8d155d12298af8d'
          ]
        }
      },
      'Activity-d6fd78907a8ce6a2d01e61ee6bb82439' => {
        'Transition-c1b6046d2b28bafc78d70fca59aefcfd' => {
          'ActivityEntityID' => 'Activity-c3eadf55a512904663b20e95a8ac67f9',
          'TransitionAction' => [
            'TransitionAction-a2a0470400d5dd8f6dba3c04d412060e'
          ]
        },
        'Transition-dabeeff4f023293efdf7550da4c2e102' => {
          'ActivityEntityID' => 'Activity-0f1ba4865b04ac860f4a775bb8f456aa',
          'TransitionAction' => [
            'TransitionAction-dd378b27493d37e5caa29750249acb44'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-d476bf12e1684c6763210fe58ae86aac',
    'StartActivityDialog' => 'ActivityDialog-f7b22bc5326b71e7ac13a3a670af569b',
    'State' => 'Inactive',
    'StateEntityID' => 'S2'
  },
  'Process-97018c99b310c7426343f6eb090bf6cf' => {
    'ChangeTime' => '2026-01-28 11:06:42',
    'CreateTime' => '2021-01-11 15:18:02',
    'Name' => 'Chamado Diária em Posto Fiscal',
    'Path' => {
      'Activity-5d38f0596b21a8a54cec4ff9167258ef' => {
        'Transition-38ba95ab67fdff823560f3dc546eea61' => {
          'ActivityEntityID' => 'Activity-9add24a386bbdc6974e839a70852dd1a',
          'TransitionAction' => [
            'TransitionAction-ef11e06905bcb3ceb65cfb54306121d8'
          ]
        }
      },
      'Activity-6c270e773e769c60bd917c6b24c5524b' => {
        'Transition-3e5afc39e3984a1074a7dcf6afdbb6de' => {
          'ActivityEntityID' => 'Activity-5d38f0596b21a8a54cec4ff9167258ef',
          'TransitionAction' => [
            'TransitionAction-cd8bda1518d5a1b9036b1324affedb76',
            'TransitionAction-675c0fa85a10528965a10b1641d01271'
          ]
        },
        'Transition-f6dcf6d1b326a7f5df2f27fca16d89da' => {
          'ActivityEntityID' => 'Activity-b70d5c71c401fc7910610c011c92e237',
          'TransitionAction' => [
            'TransitionAction-88d9974c46daaca24f268f4dc6ac9338',
            'TransitionAction-e1d7afada5772cd267cdc544149e3975',
            'TransitionAction-675c0fa85a10528965a10b1641d01271'
          ]
        }
      },
      'Activity-9add24a386bbdc6974e839a70852dd1a' => {},
      'Activity-b70d5c71c401fc7910610c011c92e237' => {
        'Transition-9732d59bce43b339eb81e4870f12f061' => {
          'ActivityEntityID' => 'Activity-f7b065f4de20056ec45fb1072cdfdb9c',
          'TransitionAction' => [
            'TransitionAction-ef11e06905bcb3ceb65cfb54306121d8'
          ]
        },
        'Transition-e6aa5f5588a66dbebd492d8b3be5bc53' => {
          'ActivityEntityID' => 'Activity-5d38f0596b21a8a54cec4ff9167258ef',
          'TransitionAction' => [
            'TransitionAction-cd8bda1518d5a1b9036b1324affedb76'
          ]
        }
      },
      'Activity-f7b065f4de20056ec45fb1072cdfdb9c' => {}
    },
    'StartActivity' => 'Activity-6c270e773e769c60bd917c6b24c5524b',
    'StartActivityDialog' => 'ActivityDialog-c358079ebd217f3b6bac5359d59ac82f',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-a0a908b48965ce51bc22e44e3e93bb4e' => {
    'ChangeTime' => '2026-01-28 11:07:27',
    'CreateTime' => '2021-01-11 15:18:29',
    'Name' => 'Chamado Diária Troca de Nota',
    'Path' => {
      'Activity-6ccb0e4bb3bb510c91c873e965c15a82' => {},
      'Activity-769993e5f07b1a0ff3e93cc60c6506c6' => {
        'Transition-9732d59bce43b339eb81e4870f12f061' => {
          'ActivityEntityID' => 'Activity-6ccb0e4bb3bb510c91c873e965c15a82',
          'TransitionAction' => [
            'TransitionAction-ef11e06905bcb3ceb65cfb54306121d8'
          ]
        },
        'Transition-e6aa5f5588a66dbebd492d8b3be5bc53' => {
          'ActivityEntityID' => 'Activity-8ffcefe41b9f127ce905a85e5a873f22',
          'TransitionAction' => [
            'TransitionAction-cd8bda1518d5a1b9036b1324affedb76'
          ]
        }
      },
      'Activity-790d60bcfa4a93b7c74381fcc5c8ecf3' => {},
      'Activity-8047dfdce655e79e92f7f652c8e5895d' => {
        'Transition-3e5afc39e3984a1074a7dcf6afdbb6de' => {
          'ActivityEntityID' => 'Activity-8ffcefe41b9f127ce905a85e5a873f22',
          'TransitionAction' => [
            'TransitionAction-cd8bda1518d5a1b9036b1324affedb76',
            'TransitionAction-675c0fa85a10528965a10b1641d01271'
          ]
        },
        'Transition-f6dcf6d1b326a7f5df2f27fca16d89da' => {
          'ActivityEntityID' => 'Activity-769993e5f07b1a0ff3e93cc60c6506c6',
          'TransitionAction' => [
            'TransitionAction-88d9974c46daaca24f268f4dc6ac9338',
            'TransitionAction-4ad6a81896259544f48b7774cb4b2086',
            'TransitionAction-675c0fa85a10528965a10b1641d01271'
          ]
        }
      },
      'Activity-8ffcefe41b9f127ce905a85e5a873f22' => {
        'Transition-38ba95ab67fdff823560f3dc546eea61' => {
          'ActivityEntityID' => 'Activity-790d60bcfa4a93b7c74381fcc5c8ecf3',
          'TransitionAction' => [
            'TransitionAction-ef11e06905bcb3ceb65cfb54306121d8'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-8047dfdce655e79e92f7f652c8e5895d',
    'StartActivityDialog' => 'ActivityDialog-b63401ae0715ef538233f7be338af8b7',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-ad2e5a5f9ef57a1025737cf457e8a46d' => {
    'ChangeTime' => '2022-01-21 15:49:56',
    'CreateTime' => '2022-01-21 10:15:52',
    'Name' => 'Chamado Multa Excesso de Peso',
    'Path' => {
      'Activity-77c1f5d4458fa31f5d86342e500726c0' => {},
      'Activity-d9eae2e12269e7ead3b5ca4908d003a1' => {
        'Transition-ae44b839409e478af79f39ab40a6a9fc' => {
          'ActivityEntityID' => 'Activity-77c1f5d4458fa31f5d86342e500726c0',
          'TransitionAction' => [
            'TransitionAction-c61afa256e989875593bb36b60f59222',
            'TransitionAction-8911d4914cd821eb106947a18e124803',
            'TransitionAction-9b8edf0bb9e4f5e1711758b1b51296e2'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-d9eae2e12269e7ead3b5ca4908d003a1',
    'StartActivityDialog' => 'ActivityDialog-aaaff07b1626b48ca1d99827286490fd',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-ad6521487c4f38dfe7e773b38173223e' => {
    'ChangeTime' => '2021-12-20 15:06:26',
    'CreateTime' => '2021-12-15 14:41:33',
    'Name' => 'Logística Operações',
    'Path' => {
      'Activity-51c8b631bd9795198fa546d9bfab6a6f' => {
        'Transition-36670ac429deef13254d3e2c5ca12c47' => {
          'ActivityEntityID' => 'Activity-c0f5cc3fceb10bd1f50d0a24a6aed5cb',
          'TransitionAction' => [
            'TransitionAction-f588eddbc41c73670b1c766301fae776',
            'TransitionAction-daee4c43872a8a72e00b4cb39f99f984',
            'TransitionAction-2be8a4ef822b1011e3625fb47304e857'
          ]
        }
      },
      'Activity-c0f5cc3fceb10bd1f50d0a24a6aed5cb' => {}
    },
    'StartActivity' => 'Activity-51c8b631bd9795198fa546d9bfab6a6f',
    'StartActivityDialog' => 'ActivityDialog-6416899c0870f089522e187fbbe86d92',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-b4afada8d023a27dcc558935ad7d8eda' => {
    'ChangeTime' => '2021-12-15 13:42:04',
    'CreateTime' => '2021-04-08 09:52:55',
    'Name' => 'Chamado Divergência Conta Corrente',
    'Path' => {
      'Activity-092d00416ee4d63c82abd97a0f961e0c' => {
        'Transition-02c6dc419318b54983e9aee5c4daf0eb' => {
          'ActivityEntityID' => 'Activity-544db83c35ce8d63d305b07d9ed692c8',
          'TransitionAction' => [
            'TransitionAction-fd4c1baba143103fc3b40dbe1ac4b7ba'
          ]
        }
      },
      'Activity-544db83c35ce8d63d305b07d9ed692c8' => {}
    },
    'StartActivity' => 'Activity-092d00416ee4d63c82abd97a0f961e0c',
    'StartActivityDialog' => 'ActivityDialog-1bbe1744824e49a4e4897019e144fb4c',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-bbfccb85289bca9f6a15833bf61e7451' => {
    'ChangeTime' => '2021-12-15 13:45:59',
    'CreateTime' => '2021-04-06 16:51:03',
    'Name' => 'Chamado Pesquisa Novo Motorista',
    'Path' => {
      'Activity-4661851f4504c5125d6156e4825dc472' => {
        'Transition-80d179e7bf73c3ebd8107625843e3fa5' => {
          'ActivityEntityID' => 'Activity-ab411f57219f296a861da4c107828340',
          'TransitionAction' => [
            'TransitionAction-68334a2ce8bd1e85c1fdc9d42828d927'
          ]
        }
      },
      'Activity-6346dbe86ffbc80b0ea8ca944809233c' => {
        'Transition-819b733fbb008f147bc1d473107495b7' => {
          'ActivityEntityID' => 'Activity-4661851f4504c5125d6156e4825dc472',
          'TransitionAction' => [
            'TransitionAction-abb7107f894d5c4566b5af5c43db8081',
            'TransitionAction-85ca04cf2975e6496758edd4db971e39',
            'TransitionAction-09213ca1fc2cf944b938c96264a0b763'
          ]
        }
      },
      'Activity-ab411f57219f296a861da4c107828340' => {}
    },
    'StartActivity' => 'Activity-6346dbe86ffbc80b0ea8ca944809233c',
    'StartActivityDialog' => 'ActivityDialog-1e7f771b08285cea0537124d9b597e66',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-c363627f07c8b2f363807320c408a1cf' => {
    'ChangeTime' => '2026-07-29 17:39:10',
    'CreateTime' => '2021-10-25 11:08:51',
    'Name' => 'Chamado Desligamento de Motorista',
    'Path' => {
      'Activity-62ec9f2a658e411165b918610c970a50' => {
        'Transition-b03e4c9acf876a5feb737f89508b0e05' => {
          'ActivityEntityID' => 'Activity-b549bda55b80861dd38ac1bb0f0be69c',
          'TransitionAction' => [
            'TransitionAction-32ae8266aed03f86eda026045d026d94',
            'TransitionAction-975c5ec99e3b9efa913f26ffb183cd35',
            'TransitionAction-67ff9abbee698e8ca81cec8f259ee8c7',
            'TransitionAction-b2e244161887a88a00b07c1febb4407c'
          ]
        }
      },
      'Activity-b549bda55b80861dd38ac1bb0f0be69c' => {}
    },
    'StartActivity' => 'Activity-62ec9f2a658e411165b918610c970a50',
    'StartActivityDialog' => 'ActivityDialog-ff022068cf5bb3c6035c468cb3a311b0',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-c80c2856e52af2194c77452017c07b4a' => {
    'ChangeTime' => '2026-08-06 14:37:56',
    'CreateTime' => '2026-03-31 11:43:49',
    'Name' => 'Colocar numero do chamado nstech',
    'Path' => {
      'Activity-cbb27580a384ca5db1bb0644b6ead582' => {}
    },
    'StartActivity' => 'Activity-cbb27580a384ca5db1bb0644b6ead582',
    'StartActivityDialog' => 'ActivityDialog-32ba1fe9bcfdbfdff329658a8ad365e9',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-cc83c965d123ff5b29595d2329f4edea' => {
    'ChangeTime' => '2023-07-03 11:20:21',
    'CreateTime' => '2021-07-14 11:08:57',
    'Name' => 'Chamado Frete Devolução',
    'Path' => {
      'Activity-1be67e6c0c9b8de86a6fac46eab0119d' => {},
      'Activity-85cecd0a202e2ed04fba3e801f8ed524' => {
        'Transition-bb4e1bf45c1fbf0374c300c5860c23ef' => {
          'ActivityEntityID' => 'Activity-d0c051bf20525a823503926d19151257'
        },
        'Transition-e45bdbd464424ee80f7806a3d2709075' => {
          'ActivityEntityID' => 'Activity-1be67e6c0c9b8de86a6fac46eab0119d',
          'TransitionAction' => [
            'TransitionAction-82e4af68d358b82c6ff035863bcd28e4',
            'TransitionAction-8d2e90e8d083cc1db4e4d4f8bc6cee9d',
            'TransitionAction-bab9726be4776509fe086e28fb1c1170'
          ]
        }
      },
      'Activity-d0c051bf20525a823503926d19151257' => {}
    },
    'StartActivity' => 'Activity-85cecd0a202e2ed04fba3e801f8ed524',
    'StartActivityDialog' => 'ActivityDialog-31530c3cd24925fb400dc24f9fc9248d',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-daf4f0a0be940199427572f084496e73' => {
    'ChangeTime' => '2022-01-12 10:42:05',
    'CreateTime' => '2020-11-23 14:32:00',
    'Name' => 'Chamado Anulação - Inativo',
    'Path' => {
      'Activity-0e55c480740345b175b0a9e466b3cc4f' => {
        'Transition-3e5afc39e3984a1074a7dcf6afdbb6de' => {
          'ActivityEntityID' => 'Activity-8404e6b49a5b79a00d05e5c1a9eb3bc6',
          'TransitionAction' => [
            'TransitionAction-33558b2f71f0f78ae34ea82abe4d411c'
          ]
        }
      },
      'Activity-8404e6b49a5b79a00d05e5c1a9eb3bc6' => {}
    },
    'StartActivity' => 'Activity-0e55c480740345b175b0a9e466b3cc4f',
    'StartActivityDialog' => 'ActivityDialog-03bf516d8db4f8202abee65a8f24c5ac',
    'State' => 'Inactive',
    'StateEntityID' => 'S2'
  },
  'Process-dde05dc9069dfdb1669e3cc8cab0ac04' => {
    'ChangeTime' => '2023-10-30 08:44:03',
    'CreateTime' => '2022-05-04 08:42:36',
    'Name' => 'Reembolso Circuitos',
    'Path' => {
      'Activity-7f894258e72b7b4ab258a1d9474ff927' => {},
      'Activity-883be8389d2a992ca970e2f72de84273' => {
        'Transition-0491e5279ec69e5fd58521b38287d375' => {
          'ActivityEntityID' => 'Activity-7f894258e72b7b4ab258a1d9474ff927',
          'TransitionAction' => [
            'TransitionAction-5e90e23e1c8bcbf147445e881f6998f4',
            'TransitionAction-5d1b7856b97d334757259d4a79d266ea'
          ]
        },
        'Transition-bb4e1bf45c1fbf0374c300c5860c23ef' => {
          'ActivityEntityID' => 'Activity-d0c051bf20525a823503926d19151257'
        }
      },
      'Activity-d0c051bf20525a823503926d19151257' => {}
    },
    'StartActivity' => 'Activity-883be8389d2a992ca970e2f72de84273',
    'StartActivityDialog' => 'ActivityDialog-77c8f549920ff4dc040a19ff22a9224e',
    'State' => 'Inactive',
    'StateEntityID' => 'S2'
  },
  'Process-e8b53c963d58c49c4e762d95a99fb686' => {
    'ChangeTime' => '2023-11-13 09:34:39',
    'CreateTime' => '2021-01-11 15:18:56',
    'Name' => 'Chamado Pedágio',
    'Path' => {
      'Activity-3ef286f93e3cd0a72699a8b7406f5f0a' => {
        'Transition-3e5afc39e3984a1074a7dcf6afdbb6de' => {
          'ActivityEntityID' => 'Activity-a81098092f5590fbe7d166a102ab98fe',
          'TransitionAction' => [
            'TransitionAction-32ae8266aed03f86eda026045d026d94',
            'TransitionAction-91e6b6251202637bf56bf6f5579910cb',
            'TransitionAction-675c0fa85a10528965a10b1641d01271'
          ]
        },
        'Transition-f6dcf6d1b326a7f5df2f27fca16d89da' => {
          'ActivityEntityID' => 'Activity-6f190e04413a5d9f015df65727d5d1ae',
          'TransitionAction' => [
            'TransitionAction-88d9974c46daaca24f268f4dc6ac9338',
            'TransitionAction-91e6b6251202637bf56bf6f5579910cb'
          ]
        }
      },
      'Activity-55292d234f8bb2487f5b5c7fdd4819f9' => {},
      'Activity-5f1fc9524864fd54d4bb4579e8eaa00d' => {},
      'Activity-6f190e04413a5d9f015df65727d5d1ae' => {
        'Transition-9732d59bce43b339eb81e4870f12f061' => {
          'ActivityEntityID' => 'Activity-5f1fc9524864fd54d4bb4579e8eaa00d',
          'TransitionAction' => [
            'TransitionAction-ef11e06905bcb3ceb65cfb54306121d8'
          ]
        },
        'Transition-e6aa5f5588a66dbebd492d8b3be5bc53' => {
          'ActivityEntityID' => 'Activity-a81098092f5590fbe7d166a102ab98fe',
          'TransitionAction' => [
            'TransitionAction-cd8bda1518d5a1b9036b1324affedb76'
          ]
        }
      },
      'Activity-a81098092f5590fbe7d166a102ab98fe' => {
        'Transition-38ba95ab67fdff823560f3dc546eea61' => {
          'ActivityEntityID' => 'Activity-55292d234f8bb2487f5b5c7fdd4819f9',
          'TransitionAction' => [
            'TransitionAction-ef11e06905bcb3ceb65cfb54306121d8'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-3ef286f93e3cd0a72699a8b7406f5f0a',
    'StartActivityDialog' => 'ActivityDialog-1706111e7d5f598897f915110342d1f0',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-edc94ee47d6af17bd958cf47bd0a50f4' => {
    'ChangeTime' => '2022-07-28 17:32:24',
    'CreateTime' => '2022-07-28 17:32:24',
    'Name' => 'Reembolso de Despesa Conselheiros(copiar)',
    'Path' => {
      'Activity-0afcf95ae9300cf50db74bc032ecdaac' => {},
      'Activity-c291bd8263ea54f847191586f719c203' => {
        'Transition-fbfe21997a1fae4f3b20af3e7e77a219' => {
          'ActivityEntityID' => 'Activity-0afcf95ae9300cf50db74bc032ecdaac',
          'TransitionAction' => [
            'TransitionAction-e6a3a3823ddbbec12e54389c12a0f003'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-c291bd8263ea54f847191586f719c203',
    'StartActivityDialog' => 'ActivityDialog-67c537a7243273883f729c09383753a4',
    'State' => 'Inactive',
    'StateEntityID' => 'S2'
  },
  'Process-f0cadeb17523c1002104bffc80ebe225' => {
    'ChangeTime' => '2026-01-28 11:05:22',
    'CreateTime' => '2023-01-26 15:20:05',
    'Name' => 'Chamado Diária na Devolução',
    'Path' => {
      'Activity-1be67e6c0c9b8de86a6fac46eab0119d' => {},
      'Activity-3f2ae3a3d1f6ffd4db0bfd458b8f3372' => {},
      'Activity-6323b5250165b54849b0b203eaf8243a' => {
        'Transition-ab5d74c796f2ac79043f3083e5c18563' => {
          'ActivityEntityID' => 'Activity-3f2ae3a3d1f6ffd4db0bfd458b8f3372',
          'TransitionAction' => [
            'TransitionAction-68334a2ce8bd1e85c1fdc9d42828d927'
          ]
        }
      },
      'Activity-e2a00fa5a6f60667b8a82fc4e2921bab' => {
        'Transition-3e5afc39e3984a1074a7dcf6afdbb6de' => {
          'ActivityEntityID' => 'Activity-6323b5250165b54849b0b203eaf8243a',
          'TransitionAction' => [
            'TransitionAction-5e90e23e1c8bcbf147445e881f6998f4',
            'TransitionAction-8ea23ab728d824583dc33d2719caaad0',
            'TransitionAction-675c0fa85a10528965a10b1641d01271'
          ]
        },
        'Transition-bb4e1bf45c1fbf0374c300c5860c23ef' => {
          'ActivityEntityID' => 'Activity-1be67e6c0c9b8de86a6fac46eab0119d',
          'TransitionAction' => [
            'TransitionAction-e71b81ccf4892ad2d8d0738123ca2c75',
            'TransitionAction-8ea23ab728d824583dc33d2719caaad0',
            'TransitionAction-675c0fa85a10528965a10b1641d01271'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-e2a00fa5a6f60667b8a82fc4e2921bab',
    'StartActivityDialog' => 'ActivityDialog-b3ab90b93dfe94a87d5bfdeffc3cec0c',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-f14c589722fce36e0e16ceac510dedd0' => {
    'ChangeTime' => '2023-07-03 09:32:55',
    'CreateTime' => '2021-12-10 10:41:15',
    'Name' => 'Chamado Fila Contas a Receber',
    'Path' => {
      'Activity-09c7a779cec90d17df0ccf505a606628' => {
        'Transition-911980b238486f413d9320e5364479a7' => {
          'ActivityEntityID' => 'Activity-f7676b9a10db3769a97f86ab84db3750',
          'TransitionAction' => [
            'TransitionAction-c132278236aa0f0129b02d989c86bf00',
            'TransitionAction-4adfb73fb5a3702474ef646b000251ab',
            'TransitionAction-4bf6f1bb5effdf01ab49e3cac4ffff94',
            'TransitionAction-30dfec830ae45951ee4cdde466c96d17'
          ]
        }
      },
      'Activity-174e2ee2942904a473f1b963df55b6d6' => {
        'Transition-218de6a132a88e941a43399579449833' => {
          'ActivityEntityID' => 'Activity-467c61a83eafecd33c87131e8fcaca25',
          'TransitionAction' => [
            'TransitionAction-48e638cae1ce9e0dbc9705ee4126da26'
          ]
        },
        'Transition-a0c40120fa47764c95e3e4a211ca658e' => {
          'ActivityEntityID' => 'Activity-9289fd2e0184c933551e701205e5fa73',
          'TransitionAction' => [
            'TransitionAction-8c1943e880c49d3ddc89ee5c170c4730',
            'TransitionAction-455bb02c17e044d4cf0c0123fb0341a6',
            'TransitionAction-30dfec830ae45951ee4cdde466c96d17',
            'TransitionAction-4bf6f1bb5effdf01ab49e3cac4ffff94'
          ]
        }
      },
      'Activity-199c3b2119820fdf009b803b55f8d727' => {
        'Transition-911980b238486f413d9320e5364479a7' => {
          'ActivityEntityID' => 'Activity-c340d91224f8f03eecabab5b47025ddb',
          'TransitionAction' => [
            'TransitionAction-c132278236aa0f0129b02d989c86bf00',
            'TransitionAction-4adfb73fb5a3702474ef646b000251ab',
            'TransitionAction-30dfec830ae45951ee4cdde466c96d17',
            'TransitionAction-4bf6f1bb5effdf01ab49e3cac4ffff94'
          ]
        }
      },
      'Activity-23cd6318053fbc135851ecc3939fcc82' => {
        'Transition-911980b238486f413d9320e5364479a7' => {
          'ActivityEntityID' => 'Activity-908cc1f7b5beda9fcfe0277a80652e5b',
          'TransitionAction' => [
            'TransitionAction-4adfb73fb5a3702474ef646b000251ab',
            'TransitionAction-c132278236aa0f0129b02d989c86bf00',
            'TransitionAction-30dfec830ae45951ee4cdde466c96d17',
            'TransitionAction-4bf6f1bb5effdf01ab49e3cac4ffff94',
            'TransitionAction-0de7f5c2ff4339a44dfed76d039f7983'
          ]
        }
      },
      'Activity-3f722335bd6799a6321ca4278ae9d865' => {},
      'Activity-467c61a83eafecd33c87131e8fcaca25' => {},
      'Activity-4a4a9349f889d94810dc6f0fa47e0db8' => {
        'Transition-911980b238486f413d9320e5364479a7' => {
          'ActivityEntityID' => 'Activity-c0346b18fb40af814e11aa762d1ffdc7',
          'TransitionAction' => [
            'TransitionAction-c132278236aa0f0129b02d989c86bf00',
            'TransitionAction-4adfb73fb5a3702474ef646b000251ab',
            'TransitionAction-30dfec830ae45951ee4cdde466c96d17',
            'TransitionAction-4bf6f1bb5effdf01ab49e3cac4ffff94'
          ]
        }
      },
      'Activity-52050c0d1519366bdd19db4b16e40575' => {
        'Transition-218de6a132a88e941a43399579449833' => {
          'ActivityEntityID' => 'Activity-f26f196baca5bed39288c905c9a061b6',
          'TransitionAction' => [
            'TransitionAction-a1c0ee1faa0d70d54144034283c21753'
          ]
        },
        'Transition-a0c40120fa47764c95e3e4a211ca658e' => {
          'ActivityEntityID' => 'Activity-53aef476acf2cbd379625349533aedbb',
          'TransitionAction' => [
            'TransitionAction-4493e3aa9d49e464cb232315dab10ef6',
            'TransitionAction-455bb02c17e044d4cf0c0123fb0341a6',
            'TransitionAction-30dfec830ae45951ee4cdde466c96d17',
            'TransitionAction-4bf6f1bb5effdf01ab49e3cac4ffff94'
          ]
        }
      },
      'Activity-53aef476acf2cbd379625349533aedbb' => {
        'Transition-911980b238486f413d9320e5364479a7' => {
          'ActivityEntityID' => 'Activity-52050c0d1519366bdd19db4b16e40575',
          'TransitionAction' => [
            'TransitionAction-c132278236aa0f0129b02d989c86bf00',
            'TransitionAction-4adfb73fb5a3702474ef646b000251ab',
            'TransitionAction-30dfec830ae45951ee4cdde466c96d17',
            'TransitionAction-4bf6f1bb5effdf01ab49e3cac4ffff94',
            'TransitionAction-0de7f5c2ff4339a44dfed76d039f7983'
          ]
        }
      },
      'Activity-5f2db9b58b7c12c6e10997d182ce4280' => {
        'Transition-218de6a132a88e941a43399579449833' => {
          'ActivityEntityID' => 'Activity-a84e71cfbdf4179a983b684c95955aec',
          'TransitionAction' => [
            'TransitionAction-48e638cae1ce9e0dbc9705ee4126da26'
          ]
        },
        'Transition-a0c40120fa47764c95e3e4a211ca658e' => {
          'ActivityEntityID' => 'Activity-64d9a841bd357e858104fc24eba5aa37',
          'TransitionAction' => [
            'TransitionAction-8c1943e880c49d3ddc89ee5c170c4730',
            'TransitionAction-455bb02c17e044d4cf0c0123fb0341a6',
            'TransitionAction-30dfec830ae45951ee4cdde466c96d17',
            'TransitionAction-4bf6f1bb5effdf01ab49e3cac4ffff94'
          ]
        }
      },
      'Activity-64d9a841bd357e858104fc24eba5aa37' => {
        'Transition-911980b238486f413d9320e5364479a7' => {
          'ActivityEntityID' => 'Activity-5f2db9b58b7c12c6e10997d182ce4280',
          'TransitionAction' => [
            'TransitionAction-c132278236aa0f0129b02d989c86bf00',
            'TransitionAction-4adfb73fb5a3702474ef646b000251ab',
            'TransitionAction-30dfec830ae45951ee4cdde466c96d17',
            'TransitionAction-4bf6f1bb5effdf01ab49e3cac4ffff94'
          ]
        }
      },
      'Activity-72e0bcfca21fbe5c7d8d71457f235eb7' => {},
      'Activity-82daa72c8941a93017420acb85d87dcf' => {},
      'Activity-830926bc9f40c4b5d98c0bbbab9a1f94' => {
        'Transition-911980b238486f413d9320e5364479a7' => {
          'ActivityEntityID' => 'Activity-bdf29040e889549821aaabfbbda968f4',
          'TransitionAction' => [
            'TransitionAction-c132278236aa0f0129b02d989c86bf00',
            'TransitionAction-4adfb73fb5a3702474ef646b000251ab',
            'TransitionAction-30dfec830ae45951ee4cdde466c96d17',
            'TransitionAction-4bf6f1bb5effdf01ab49e3cac4ffff94'
          ]
        }
      },
      'Activity-908cc1f7b5beda9fcfe0277a80652e5b' => {
        'Transition-218de6a132a88e941a43399579449833' => {
          'ActivityEntityID' => 'Activity-3f722335bd6799a6321ca4278ae9d865',
          'TransitionAction' => [
            'TransitionAction-a1c0ee1faa0d70d54144034283c21753'
          ]
        },
        'Transition-a0c40120fa47764c95e3e4a211ca658e' => {
          'ActivityEntityID' => 'Activity-23cd6318053fbc135851ecc3939fcc82',
          'TransitionAction' => [
            'TransitionAction-4493e3aa9d49e464cb232315dab10ef6',
            'TransitionAction-c8c73021d1698951bd81e76dfb330cd2',
            'TransitionAction-30dfec830ae45951ee4cdde466c96d17',
            'TransitionAction-4bf6f1bb5effdf01ab49e3cac4ffff94',
            'TransitionAction-0de7f5c2ff4339a44dfed76d039f7983'
          ]
        }
      },
      'Activity-9289fd2e0184c933551e701205e5fa73' => {
        'Transition-911980b238486f413d9320e5364479a7' => {
          'ActivityEntityID' => 'Activity-174e2ee2942904a473f1b963df55b6d6',
          'TransitionAction' => [
            'TransitionAction-8c1943e880c49d3ddc89ee5c170c4730',
            'TransitionAction-4adfb73fb5a3702474ef646b000251ab',
            'TransitionAction-30dfec830ae45951ee4cdde466c96d17',
            'TransitionAction-4bf6f1bb5effdf01ab49e3cac4ffff94'
          ]
        }
      },
      'Activity-959f74348ab50f357234476d961ea201' => {},
      'Activity-a84e71cfbdf4179a983b684c95955aec' => {},
      'Activity-a93150b729404c9853ff80e42d069fc2' => {
        'Transition-218de6a132a88e941a43399579449833' => {
          'ActivityEntityID' => 'Activity-959f74348ab50f357234476d961ea201',
          'TransitionAction' => [
            'TransitionAction-a1c0ee1faa0d70d54144034283c21753',
            'TransitionAction-0de7f5c2ff4339a44dfed76d039f7983'
          ]
        },
        'Transition-a0c40120fa47764c95e3e4a211ca658e' => {
          'ActivityEntityID' => 'Activity-d0983a8cd2661ae6b10e3ac46ce872b8',
          'TransitionAction' => [
            'TransitionAction-4493e3aa9d49e464cb232315dab10ef6',
            'TransitionAction-c8c73021d1698951bd81e76dfb330cd2',
            'TransitionAction-30dfec830ae45951ee4cdde466c96d17'
          ]
        }
      },
      'Activity-bda528801e304b6a9df57a0ecc830e7e' => {},
      'Activity-bdf29040e889549821aaabfbbda968f4' => {
        'Transition-218de6a132a88e941a43399579449833' => {
          'ActivityEntityID' => 'Activity-cdd1fbff636742422aeadfbf5904b6e7',
          'TransitionAction' => [
            'TransitionAction-a1c0ee1faa0d70d54144034283c21753'
          ]
        },
        'Transition-a0c40120fa47764c95e3e4a211ca658e' => {
          'ActivityEntityID' => 'Activity-830926bc9f40c4b5d98c0bbbab9a1f94',
          'TransitionAction' => [
            'TransitionAction-8c1943e880c49d3ddc89ee5c170c4730',
            'TransitionAction-455bb02c17e044d4cf0c0123fb0341a6',
            'TransitionAction-30dfec830ae45951ee4cdde466c96d17',
            'TransitionAction-4bf6f1bb5effdf01ab49e3cac4ffff94'
          ]
        }
      },
      'Activity-c0346b18fb40af814e11aa762d1ffdc7' => {
        'Transition-218de6a132a88e941a43399579449833' => {
          'ActivityEntityID' => 'Activity-82daa72c8941a93017420acb85d87dcf',
          'TransitionAction' => [
            'TransitionAction-a1c0ee1faa0d70d54144034283c21753'
          ]
        },
        'Transition-a0c40120fa47764c95e3e4a211ca658e' => {
          'ActivityEntityID' => 'Activity-4a4a9349f889d94810dc6f0fa47e0db8',
          'TransitionAction' => [
            'TransitionAction-4493e3aa9d49e464cb232315dab10ef6',
            'TransitionAction-c8c73021d1698951bd81e76dfb330cd2',
            'TransitionAction-4bf6f1bb5effdf01ab49e3cac4ffff94',
            'TransitionAction-30dfec830ae45951ee4cdde466c96d17'
          ]
        }
      },
      'Activity-c340d91224f8f03eecabab5b47025ddb' => {
        'Transition-218de6a132a88e941a43399579449833' => {
          'ActivityEntityID' => 'Activity-72e0bcfca21fbe5c7d8d71457f235eb7',
          'TransitionAction' => [
            'TransitionAction-a1c0ee1faa0d70d54144034283c21753'
          ]
        },
        'Transition-a0c40120fa47764c95e3e4a211ca658e' => {
          'ActivityEntityID' => 'Activity-199c3b2119820fdf009b803b55f8d727',
          'TransitionAction' => [
            'TransitionAction-8c1943e880c49d3ddc89ee5c170c4730',
            'TransitionAction-455bb02c17e044d4cf0c0123fb0341a6',
            'TransitionAction-4bf6f1bb5effdf01ab49e3cac4ffff94',
            'TransitionAction-30dfec830ae45951ee4cdde466c96d17',
            'TransitionAction-8880f04868ee17fd8cb37d1e34c4fd42'
          ]
        }
      },
      'Activity-cdd1fbff636742422aeadfbf5904b6e7' => {},
      'Activity-d0983a8cd2661ae6b10e3ac46ce872b8' => {
        'Transition-911980b238486f413d9320e5364479a7' => {
          'ActivityEntityID' => 'Activity-a93150b729404c9853ff80e42d069fc2',
          'TransitionAction' => [
            'TransitionAction-c132278236aa0f0129b02d989c86bf00',
            'TransitionAction-4adfb73fb5a3702474ef646b000251ab',
            'TransitionAction-30dfec830ae45951ee4cdde466c96d17',
            'TransitionAction-4bf6f1bb5effdf01ab49e3cac4ffff94'
          ]
        }
      },
      'Activity-e083e58726f5bb6c1bd0b20ea62b1cc4' => {
        'Transition-1f1745ca2265dede7d7e5e82eb47ba7a' => {
          'ActivityEntityID' => 'Activity-199c3b2119820fdf009b803b55f8d727',
          'TransitionAction' => [
            'TransitionAction-8c1943e880c49d3ddc89ee5c170c4730',
            'TransitionAction-7d9c98651580b36cdc3e279881315b3a',
            'TransitionAction-78b47684cb7f8e9bce181b384b4c3c91',
            'TransitionAction-455bb02c17e044d4cf0c0123fb0341a6',
            'TransitionAction-0de7f5c2ff4339a44dfed76d039f7983'
          ]
        },
        'Transition-24e5fe190fc42ecc7243fb10a21510fc' => {
          'ActivityEntityID' => 'Activity-830926bc9f40c4b5d98c0bbbab9a1f94',
          'TransitionAction' => [
            'TransitionAction-8c1943e880c49d3ddc89ee5c170c4730',
            'TransitionAction-d8c837018e46b682b1bae8b9eb9b1b89',
            'TransitionAction-f2c0569e2904585f38bc17de50469068',
            'TransitionAction-455bb02c17e044d4cf0c0123fb0341a6',
            'TransitionAction-0de7f5c2ff4339a44dfed76d039f7983'
          ]
        },
        'Transition-4072a96995c82b274386197fc0d4c0eb' => {
          'ActivityEntityID' => 'Activity-9289fd2e0184c933551e701205e5fa73',
          'TransitionAction' => [
            'TransitionAction-c132278236aa0f0129b02d989c86bf00',
            'TransitionAction-e6811d883d754c49b57ec7e39b6d9f17',
            'TransitionAction-ab1aa57420d09aa9f6145541c08ccfa7',
            'TransitionAction-455bb02c17e044d4cf0c0123fb0341a6',
            'TransitionAction-0de7f5c2ff4339a44dfed76d039f7983'
          ]
        },
        'Transition-7c6922530228747f5f007f2afbe209e6' => {
          'ActivityEntityID' => 'Activity-09c7a779cec90d17df0ccf505a606628',
          'TransitionAction' => [
            'TransitionAction-8c1943e880c49d3ddc89ee5c170c4730',
            'TransitionAction-03d1d295eb3efd9f0b65ae1794a88a8f',
            'TransitionAction-86abca60af091276d0a0bf3e9fb60182',
            'TransitionAction-c8c73021d1698951bd81e76dfb330cd2',
            'TransitionAction-0de7f5c2ff4339a44dfed76d039f7983'
          ]
        },
        'Transition-b093d14580a9fd1b1c34fb102222ede9' => {
          'ActivityEntityID' => 'Activity-53aef476acf2cbd379625349533aedbb',
          'TransitionAction' => [
            'TransitionAction-8c1943e880c49d3ddc89ee5c170c4730',
            'TransitionAction-a34d0b5207f266459ed761b79e69e687',
            'TransitionAction-27e3bdab617ac13823e80082ea3ab863',
            'TransitionAction-c8c73021d1698951bd81e76dfb330cd2',
            'TransitionAction-0de7f5c2ff4339a44dfed76d039f7983'
          ]
        },
        'Transition-b2a2da30b602d0617073d81b7f0ca74d' => {
          'ActivityEntityID' => 'Activity-d0983a8cd2661ae6b10e3ac46ce872b8',
          'TransitionAction' => [
            'TransitionAction-8c1943e880c49d3ddc89ee5c170c4730',
            'TransitionAction-0104186d0be3e519c41230c7b3454ee1',
            'TransitionAction-14265d6d2bcbc40191ebe7595562f39a',
            'TransitionAction-455bb02c17e044d4cf0c0123fb0341a6',
            'TransitionAction-0de7f5c2ff4339a44dfed76d039f7983'
          ]
        },
        'Transition-ca02f39684e67beff3a33fa35fb6b2f3' => {
          'ActivityEntityID' => 'Activity-4a4a9349f889d94810dc6f0fa47e0db8',
          'TransitionAction' => [
            'TransitionAction-8c1943e880c49d3ddc89ee5c170c4730',
            'TransitionAction-c8c73021d1698951bd81e76dfb330cd2',
            'TransitionAction-307189b3d58b1059bcb0918f5fcdee6a',
            'TransitionAction-63ede623962c067f6c48f5c4c8a75e21',
            'TransitionAction-0de7f5c2ff4339a44dfed76d039f7983'
          ]
        },
        'Transition-d4d35d84e153167a36f5c9b1b0cdc87f' => {
          'ActivityEntityID' => 'Activity-23cd6318053fbc135851ecc3939fcc82',
          'TransitionAction' => [
            'TransitionAction-8c1943e880c49d3ddc89ee5c170c4730',
            'TransitionAction-f76b6001bbd487af656171455d515151',
            'TransitionAction-39f7b17a45909f37b9808208b1f14d43',
            'TransitionAction-455bb02c17e044d4cf0c0123fb0341a6',
            'TransitionAction-0de7f5c2ff4339a44dfed76d039f7983'
          ]
        },
        'Transition-f8bdf3a5809fa396d66e76482032847a' => {
          'ActivityEntityID' => 'Activity-64d9a841bd357e858104fc24eba5aa37',
          'TransitionAction' => [
            'TransitionAction-8c1943e880c49d3ddc89ee5c170c4730',
            'TransitionAction-b00fe4a296e58a8f67cdb4f0d6bfa66b',
            'TransitionAction-070750085865b64f649fae056a2af695',
            'TransitionAction-455bb02c17e044d4cf0c0123fb0341a6',
            'TransitionAction-0de7f5c2ff4339a44dfed76d039f7983'
          ]
        }
      },
      'Activity-f26f196baca5bed39288c905c9a061b6' => {},
      'Activity-f7676b9a10db3769a97f86ab84db3750' => {
        'Transition-218de6a132a88e941a43399579449833' => {
          'ActivityEntityID' => 'Activity-bda528801e304b6a9df57a0ecc830e7e',
          'TransitionAction' => [
            'TransitionAction-a1c0ee1faa0d70d54144034283c21753'
          ]
        },
        'Transition-a0c40120fa47764c95e3e4a211ca658e' => {
          'ActivityEntityID' => 'Activity-09c7a779cec90d17df0ccf505a606628',
          'TransitionAction' => [
            'TransitionAction-8c1943e880c49d3ddc89ee5c170c4730',
            'TransitionAction-455bb02c17e044d4cf0c0123fb0341a6',
            'TransitionAction-4bf6f1bb5effdf01ab49e3cac4ffff94',
            'TransitionAction-30dfec830ae45951ee4cdde466c96d17'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-e083e58726f5bb6c1bd0b20ea62b1cc4',
    'StartActivityDialog' => 'ActivityDialog-acb1d3b0ab2d77fa13919847e125945c',
    'State' => 'Inactive',
    'StateEntityID' => 'S2'
  },
  'Process-f51a281c2e1df3b30b4788c9c74dc1b9' => {
    'ChangeTime' => '2022-01-12 10:42:30',
    'CreateTime' => '2020-06-26 17:23:30',
    'Name' => 'Assinatura de  Atas - Inativo',
    'Path' => {},
    'StartActivity' => '',
    'StartActivityDialog' => '',
    'State' => 'Inactive',
    'StateEntityID' => 'S2'
  },
  'Process-f581079e489db28e406e6364a62abe25' => {
    'ChangeTime' => '2023-01-04 11:10:04',
    'CreateTime' => '2023-01-04 08:59:19',
    'Name' => 'Treinamento PDC Cooperado',
    'Path' => {
      'Activity-a84e71cfbdf4179a983b684c95955aec' => {},
      'Activity-e44e0d34030fe2312558097565bec17d' => {
        'Transition-0491e5279ec69e5fd58521b38287d375' => {
          'ActivityEntityID' => 'Activity-a84e71cfbdf4179a983b684c95955aec'
        }
      }
    },
    'StartActivity' => 'Activity-e44e0d34030fe2312558097565bec17d',
    'StartActivityDialog' => 'ActivityDialog-92d8a1697eb85a2cfc436e220093f3f2',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  },
  'Process-f9db7cf70938e64af70a2688bc152d75' => {
    'ChangeTime' => '2023-07-03 15:41:34',
    'CreateTime' => '2021-01-11 15:19:27',
    'Name' => 'Chamado de Deslocamento',
    'Path' => {
      'Activity-477c6b123cf67fc7034d6f9efb47eb59' => {},
      'Activity-88f825a54d5b4267369aaff5d3c7bc2c' => {},
      'Activity-8dd168143b99cbfa342c71d9e94ec60d' => {
        'Transition-3e5afc39e3984a1074a7dcf6afdbb6de' => {
          'ActivityEntityID' => 'Activity-b8d503efb6b866a656c9394a59db1166',
          'TransitionAction' => [
            'TransitionAction-bfb0f77eacc16ef91094ac33747d6bfc',
            'TransitionAction-0a74811cba4a49debddb70f4dcbf8d1f',
            'TransitionAction-675c0fa85a10528965a10b1641d01271'
          ]
        },
        'Transition-bb4e1bf45c1fbf0374c300c5860c23ef' => {
          'ActivityEntityID' => 'Activity-88f825a54d5b4267369aaff5d3c7bc2c',
          'TransitionAction' => [
            'TransitionAction-e71b81ccf4892ad2d8d0738123ca2c75',
            'TransitionAction-0a74811cba4a49debddb70f4dcbf8d1f'
          ]
        }
      },
      'Activity-b8d503efb6b866a656c9394a59db1166' => {
        'Transition-38ba95ab67fdff823560f3dc546eea61' => {
          'ActivityEntityID' => 'Activity-477c6b123cf67fc7034d6f9efb47eb59',
          'TransitionAction' => [
            'TransitionAction-ef11e06905bcb3ceb65cfb54306121d8'
          ]
        }
      }
    },
    'StartActivity' => 'Activity-8dd168143b99cbfa342c71d9e94ec60d',
    'StartActivityDialog' => 'ActivityDialog-189c08089f5763a841a9942228fafdf3',
    'State' => 'Active',
    'StateEntityID' => 'S1'
  }
};

$Self->{'Process::State'} = {
  'S1' => 'Active',
  'S2' => 'Inactive',
  'S3' => 'FadeAway'
};

$Self->{'Process::Activity'} = {
  'Activity-018267f67c66cfcfaba3203ea6bc3430' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-4b5130064c75f7c44d14c4c2e0b6897d'
    },
    'ChangeTime' => '2025-12-11 14:03:01',
    'CreateTime' => '2025-12-11 14:01:31',
    'ID' => 194,
    'Name' => 'NewKMM - NumCarga'
  },
  'Activity-080cf398dea8d2ae20cc40cde8cd4256' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-2796352615efdd688aefeffb8905c6a1'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-06-09 16:27:00',
    'ID' => 112,
    'Name' => '1.Abertura Chamado Voz do Cooperado'
  },
  'Activity-092d00416ee4d63c82abd97a0f961e0c' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-1bbe1744824e49a4e4897019e144fb4c'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-04-08 10:08:49',
    'ID' => 108,
    'Name' => '1.Abertura Chamado Divergência Conta Corrente'
  },
  'Activity-09c7a779cec90d17df0ccf505a606628' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-59212aa9c56302096dba93e471d51744'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-07 09:18:17',
    'ID' => 158,
    'Name' => '17 - Atendimento Filial'
  },
  'Activity-0a66083031a392c083562b1c39238fd0' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-07-18 14:59:51',
    'ID' => 180,
    'Name' => '4.Encerrar Chamado Seguro de Vida'
  },
  'Activity-0afcf95ae9300cf50db74bc032ecdaac' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-2360a4eba8574a269cce5ebccdbfa945',
      '2' => 'ActivityDialog-8393955c0693dfd9ef39d077f11a2377'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-07-26 10:29:41',
    'ID' => 182,
    'Name' => 'FechaChamadoReembolsoDespesa'
  },
  'Activity-0c873649c514c33bb401e0053fe8d952' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-cfd3c4cf72e1ad07a82ab83b5c84a46c'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-03-25 17:27:10',
    'ID' => 96,
    'Name' => '3.1 Fecha Chamado Societario Reembolso de Imposto Fiscal'
  },
  'Activity-0e55c480740345b175b0a9e466b3cc4f' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-03bf516d8db4f8202abee65a8f24c5ac'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2020-11-23 14:05:43',
    'ID' => 50,
    'Name' => 'Processo exemplo'
  },
  'Activity-0f1ba4865b04ac860f4a775bb8f456aa' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-11-26 14:13:56',
    'ID' => 135,
    'Name' => '2 - Fechar Chamado Gestão de Frota Pesquisa Cavalo'
  },
  'Activity-14c45316dff58941c558a0f31cbdadd5' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-e7281b17803a9beb7008dbab2c213026',
      '2' => 'ActivityDialog-b2e090db08844bc5e0e798c4c762628f'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:15:17',
    'ID' => 51,
    'Name' => '2.Atendimento Filial Frete Bloqueado'
  },
  'Activity-1533d69188a7b66c82f50abb0c65265a' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-11-03 10:31:37',
    'ID' => 128,
    'Name' => '3. Atendimento Chamado Desloncamento'
  },
  'Activity-163208b74482e6619b88505884fc8654' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2020-11-19 14:58:25',
    'ID' => 49,
    'Name' => 'Abertura Fluxo Comercial Contratos'
  },
  'Activity-174e2ee2942904a473f1b963df55b6d6' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-2360a4eba8574a269cce5ebccdbfa945'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-16 15:25:23',
    'ID' => 165,
    'Name' => '24 - Finalizar Pallet'
  },
  'Activity-199c3b2119820fdf009b803b55f8d727' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-e3d63df245ec25b32780c3a437d3c07c'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-04 15:43:55',
    'ID' => 155,
    'Name' => '14 - Atendimento Filial'
  },
  'Activity-1afef6c13e1e46048d40a25c781c3f1b' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-16 15:39:33',
    'ID' => 166,
    'Name' => 'Chamado Encerrado'
  },
  'Activity-1be67e6c0c9b8de86a6fac46eab0119d' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-31530c3cd24925fb400dc24f9fc9248d',
      '2' => 'ActivityDialog-003f712ca1ec4d7465f438f279eed3d4'
    },
    'ChangeTime' => '2026-07-28 10:46:04',
    'CreateTime' => '2021-07-14 11:37:45',
    'ID' => 119,
    'Name' => '2.Atendimento Societário Frete Devolução'
  },
  'Activity-1c2fe55210d4cc1abf21e40007d088d7' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-ff022068cf5bb3c6035c468cb3a311b0'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-10-25 16:23:05',
    'ID' => 127,
    'Name' => '3. Ajusta Título do Processo'
  },
  'Activity-1dd58f403708893091247acafcdf6f7b' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-22c0932c26758c593b257eda069bd35b'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-04-08 09:27:06',
    'ID' => 107,
    'Name' => '3.Atendimento Societário Outras Demandas'
  },
  'Activity-1f1f75e95d2b2f93b235e00b66636c36' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-a96ea4e798e67fe9c789f87b8968c048'
    },
    'ChangeTime' => '2026-10-14 13:04:03',
    'CreateTime' => '2021-01-11 15:17:06',
    'ID' => 66,
    'Name' => '1.Abertura Chamado Diria no Carregamento'
  },
  'Activity-203f464c776e853da6a585722ff458d5' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-22c0932c26758c593b257eda069bd35b'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-04-08 09:23:00',
    'ID' => 106,
    'Name' => '1.Abertura Chamado Outras Demanadas'
  },
  'Activity-219363c9f804d2ed2ac5658712a66d5b' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-7ed7a50997e7643835f144e89bb91e27'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-04-08 10:37:59',
    'ID' => 110,
    'Name' => '1.Abertura Chamado Pesquisa Carreta'
  },
  'Activity-21cdcdf873c446c61062270e916f0a77' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-40ce57d51211544087e15b525e5be531'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2023-05-15 09:44:59',
    'ID' => 190,
    'Name' => 'Abertura Chamado Importação MultiCTE'
  },
  'Activity-220f464cfe897fc89baf93f8fc54f460' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-cfd3c4cf72e1ad07a82ab83b5c84a46c'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-03-25 17:23:28',
    'ID' => 95,
    'Name' => '3.Atendimento Societário Reembolso de Imposto Fiscal'
  },
  'Activity-23cd6318053fbc135851ecc3939fcc82' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-db31612e80e6dda76b3007c68e73c7f8'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-04 09:11:04',
    'ID' => 149,
    'Name' => '08 - Atendimento Filial'
  },
  'Activity-25239ed400a07fcd3523ba0e6f641671' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-22c0932c26758c593b257eda069bd35b'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-21 17:05:00',
    'ID' => 171,
    'Name' => 'Solicitação de Cancelamentos - LCD/Contrato/Extrato'
  },
  'Activity-299e3ba71d6faa1adeeaff062661d5b2' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-07-27 15:42:25',
    'ID' => 185,
    'Name' => 'Termina'
  },
  'Activity-29cf6d2c8f7e5b25830b8545cea7871d' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-380e90623264f051b87cf8a72e538865'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:17:38',
    'ID' => 71,
    'Name' => '2.1 Fechamento Filial Descarga'
  },
  'Activity-2c86d83e9301510b80753f5d5ecf635d' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-cbbc560d0b7e9c5300109afc16edd094'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-07-01 15:10:38',
    'ID' => 117,
    'Name' => '3.Atendimento Societário Libera Cursos'
  },
  'Activity-37f9e0592597465dae385ee9aef2ec9d' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-380e90623264f051b87cf8a72e538865',
      '2' => 'ActivityDialog-b2e090db08844bc5e0e798c4c762628f'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:17:38',
    'ID' => 72,
    'Name' => '3.Atendimento Societário Descarga'
  },
  'Activity-39da1ccd84d5000b7e4b1e59056514d6' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-fa86248da41a0fed937e7ecdac5c2db2'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-10-20 10:22:34',
    'ID' => 123,
    'Name' => '1.Abertura de Chamado Retirada de Veículo da Frota'
  },
  'Activity-3ef286f93e3cd0a72699a8b7406f5f0a' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-1706111e7d5f598897f915110342d1f0'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:18:56',
    'ID' => 86,
    'Name' => '1.Abertura Chamado Pedágio'
  },
  'Activity-3f2ae3a3d1f6ffd4db0bfd458b8f3372' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-3026fd1b4532278e9a23993204d82d5b'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:16:45',
    'ID' => 61,
    'Name' => '3.1 Fecha Chamado Societario'
  },
  'Activity-3f722335bd6799a6321ca4278ae9d865' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-04 09:42:50',
    'ID' => 151,
    'Name' => '10 - Chamado Encerrado'
  },
  'Activity-4096f787f5f1918247436ffc7924ef19' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-a96ea4e798e67fe9c789f87b8968c048'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:17:06',
    'ID' => 67,
    'Name' => '3.1 Fecha Chamado Societario Diario no Carregamento'
  },
  'Activity-43a258334bf046a15d74d99720db2fe1' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-09f119af95a3f02d4ca49a9e5784b150'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2020-06-26 17:24:34',
    'ID' => 3,
    'Name' => 'Gerar Ata'
  },
  'Activity-4661851f4504c5125d6156e4825dc472' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-1e7f771b08285cea0537124d9b597e66',
      '2' => 'ActivityDialog-aadcb869b6fff6aadc09e8e1638dc0d6'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-04-06 17:12:50',
    'ID' => 98,
    'Name' => '3.Atendimento Societário Pesquisa Motorista'
  },
  'Activity-467c61a83eafecd33c87131e8fcaca25' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-21 09:30:01',
    'ID' => 167,
    'Name' => '25 - Chamado Encerrado Pallet'
  },
  'Activity-477c6b123cf67fc7034d6f9efb47eb59' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-189c08089f5763a841a9942228fafdf3'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:19:27',
    'ID' => 91,
    'Name' => '3.1 Fecha Chamado Societario Deslocamento'
  },
  'Activity-4a0ed13ff0fe702743fc559f1e120f39' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-2de93fb09d400f1d8d30efdc23d96d82'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-07-18 11:47:25',
    'ID' => 179,
    'Name' => '3. Atendimento Seguro de Vida'
  },
  'Activity-4a4a9349f889d94810dc6f0fa47e0db8' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-d03210c58616d3f4c550c3cdd37ada73'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-01-19 15:35:19',
    'ID' => 141,
    'Name' => '05. Atendimento Filial'
  },
  'Activity-4f96554da48afd4191ce07aee15e83cf' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-dc48d1afd0dbd7e535dcd41b26d3a29e'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:15:43',
    'ID' => 56,
    'Name' => '2.1 Fechamento Filial Divergencia Valor do Frete'
  },
  'Activity-51b1b065048677c394ced9539bc5d129' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-2796352615efdd688aefeffb8905c6a1'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-06-10 09:54:02',
    'ID' => 114,
    'Name' => '3. Atendimento Voz do Societário'
  },
  'Activity-51c8b631bd9795198fa546d9bfab6a6f' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-6416899c0870f089522e187fbbe86d92'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-12-15 14:42:00',
    'ID' => 138,
    'Name' => '1. Abertura Chamado Logistica Operacoes'
  },
  'Activity-52050c0d1519366bdd19db4b16e40575' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-2360a4eba8574a269cce5ebccdbfa945'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-01-19 15:39:20',
    'ID' => 142,
    'Name' => '03 - Finalizar Anulação'
  },
  'Activity-53aef476acf2cbd379625349533aedbb' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-75fc40912458bd40408eb660e0190dd6'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-12-23 17:09:20',
    'ID' => 140,
    'Name' => '02. Atendimento Filial'
  },
  'Activity-53bf5ebd6f7d1cbfc10f2aee42106595' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-21 17:07:15',
    'ID' => 172,
    'Name' => 'Abertura de Chamado Cancelamentos'
  },
  'Activity-544db83c35ce8d63d305b07d9ed692c8' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-1bbe1744824e49a4e4897019e144fb4c'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-04-08 10:11:16',
    'ID' => 109,
    'Name' => '3.Atendimento Societário Divergencia Conta Corrente'
  },
  'Activity-547158582bb4b4e2e0ad3b44b2d33d06' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-e7281b17803a9beb7008dbab2c213026',
      '2' => 'ActivityDialog-b2e090db08844bc5e0e798c4c762628f'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:15:17',
    'ID' => 52,
    'Name' => '3.Atendimento Societário Frete Bloqueado'
  },
  'Activity-55292d234f8bb2487f5b5c7fdd4819f9' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-1706111e7d5f598897f915110342d1f0'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:18:56',
    'ID' => 87,
    'Name' => '3.1 Fecha Chamado Societario Pedágio'
  },
  'Activity-5d38f0596b21a8a54cec4ff9167258ef' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-c358079ebd217f3b6bac5359d59ac82f',
      '2' => 'ActivityDialog-b2e090db08844bc5e0e798c4c762628f'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:18:02',
    'ID' => 76,
    'Name' => '3.Atendimento Societário Diaria em Posto Fiscal'
  },
  'Activity-5db1fff06b36ff1d4f63426c1012e7fe' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-d60045da8a265ff06ffa8ea1d47e3d6e'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-07-27 15:32:32',
    'ID' => 184,
    'Name' => 'Iniciar Cadastro de Motorista'
  },
  'Activity-5ef3278b98f1efdc55e2a44327952ae1' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-a96ea4e798e67fe9c789f87b8968c048',
      '2' => 'ActivityDialog-b2e090db08844bc5e0e798c4c762628f',
      '3' => 'ActivityDialog-003f712ca1ec4d7465f438f279eed3d4'
    },
    'ChangeTime' => '2026-07-28 10:45:33',
    'CreateTime' => '2021-01-11 15:17:06',
    'ID' => 68,
    'Name' => '2.Atendimento Filial Diaria no Carregamento'
  },
  'Activity-5f1fc9524864fd54d4bb4579e8eaa00d' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-1706111e7d5f598897f915110342d1f0'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:18:56',
    'ID' => 88,
    'Name' => '2.1 Fechamento Filial Pedágio'
  },
  'Activity-5f2db9b58b7c12c6e10997d182ce4280' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-2360a4eba8574a269cce5ebccdbfa945'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-21 10:47:23',
    'ID' => 169,
    'Name' => '27 - Finalizar Entrega de Comprovante e Protocolo'
  },
  'Activity-6068118c48a0b3bb9cd4748de7735555' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-07-27 15:31:23',
    'ID' => 183,
    'Name' => 'Formulario de Cadastro de Motorista'
  },
  'Activity-62ec9f2a658e411165b918610c970a50' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-ff022068cf5bb3c6035c468cb3a311b0'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-10-25 11:09:27',
    'ID' => 125,
    'Name' => '1. Abertura de Chamado Desligamento de Motorista'
  },
  'Activity-6323b5250165b54849b0b203eaf8243a' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-3026fd1b4532278e9a23993204d82d5b',
      '2' => 'ActivityDialog-aadcb869b6fff6aadc09e8e1638dc0d6'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:16:45',
    'ID' => 62,
    'Name' => '3.Atendimento Societário'
  },
  'Activity-6346dbe86ffbc80b0ea8ca944809233c' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-1e7f771b08285cea0537124d9b597e66'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-04-06 16:58:43',
    'ID' => 97,
    'Name' => '1.Abertura Chamado Pesquisa Motorista'
  },
  'Activity-64d9a841bd357e858104fc24eba5aa37' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-aa01d2ea1c3645d0e8a85fbba65c9982'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-21 10:27:58',
    'ID' => 168,
    'Name' => '26 - Atendimento Filial'
  },
  'Activity-67dc497ded44a2f5aa4b5ff09d4fe1eb' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-be5ea986d951a966f0317882df049e6b'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-06-10 09:55:19',
    'ID' => 115,
    'Name' => '1.1 Abertura Chamado Voz do Cooperado'
  },
  'Activity-699c80279f7759c37d88c674986c2fb6' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2026-01-20 10:51:13',
    'CreateTime' => '2026-01-20 10:51:13',
    'ID' => 195,
    'Name' => 'Formulário chamado de Diária'
  },
  'Activity-6c270e773e769c60bd917c6b24c5524b' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-c358079ebd217f3b6bac5359d59ac82f'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:18:02',
    'ID' => 77,
    'Name' => '1.Abertura Chamado Diária em Posto Fiscal'
  },
  'Activity-6ccb0e4bb3bb510c91c873e965c15a82' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-b63401ae0715ef538233f7be338af8b7'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:18:29',
    'ID' => 81,
    'Name' => '2.1 Fechamento Filial Diaria Troca de Nota'
  },
  'Activity-6f190e04413a5d9f015df65727d5d1ae' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-1706111e7d5f598897f915110342d1f0',
      '2' => 'ActivityDialog-b2e090db08844bc5e0e798c4c762628f'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:18:56',
    'ID' => 89,
    'Name' => '2.Atendimento Filial Pedágio'
  },
  'Activity-72e0bcfca21fbe5c7d8d71457f235eb7' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-04 15:54:36',
    'ID' => 157,
    'Name' => '16 - Chamado Encerrado'
  },
  'Activity-76471f703e71c44e3d778fdbf897ae14' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-380e90623264f051b87cf8a72e538865'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:17:38',
    'ID' => 73,
    'Name' => '1.Abertura Chamado Recibo de Descarga'
  },
  'Activity-769993e5f07b1a0ff3e93cc60c6506c6' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-b63401ae0715ef538233f7be338af8b7',
      '2' => 'ActivityDialog-b2e090db08844bc5e0e798c4c762628f',
      '3' => 'ActivityDialog-003f712ca1ec4d7465f438f279eed3d4'
    },
    'ChangeTime' => '2026-07-28 10:46:17',
    'CreateTime' => '2021-01-11 15:18:29',
    'ID' => 82,
    'Name' => '2.Atendimento Filial Diaria Troca de Nota'
  },
  'Activity-77c1f5d4458fa31f5d86342e500726c0' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-aaaff07b1626b48ca1d99827286490fd'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-01-21 11:07:33',
    'ID' => 146,
    'Name' => '2.Atendimento Societário Multa Excesso Peso'
  },
  'Activity-790d60bcfa4a93b7c74381fcc5c8ecf3' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-b63401ae0715ef538233f7be338af8b7'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:18:29',
    'ID' => 83,
    'Name' => '3.1 Fecha Chamado Societario Diario Troca de Nota'
  },
  'Activity-7bd458a3ea9d37b3372a947727d5495f' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-e7281b17803a9beb7008dbab2c213026'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:15:17',
    'ID' => 53,
    'Name' => '1.Abertura Chamado Frete Bloqueado'
  },
  'Activity-7f894258e72b7b4ab258a1d9474ff927' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-05-04 10:40:21',
    'ID' => 174,
    'Name' => 'Atendimento CRC'
  },
  'Activity-8047dfdce655e79e92f7f652c8e5895d' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-b63401ae0715ef538233f7be338af8b7'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:18:29',
    'ID' => 84,
    'Name' => '1.Abertura Chamado Diaria Troca de Nota'
  },
  'Activity-82daa72c8941a93017420acb85d87dcf' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-01-21 10:43:24',
    'ID' => 145,
    'Name' => '07 - Chamado Encerrado'
  },
  'Activity-830926bc9f40c4b5d98c0bbbab9a1f94' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-dadc4cc9b17ac25fac464d2e76d90fdd'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-07 13:40:41',
    'ID' => 161,
    'Name' => '20 - Atendimento Filial'
  },
  'Activity-8404e6b49a5b79a00d05e5c1a9eb3bc6' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-03bf516d8db4f8202abee65a8f24c5ac'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:15:43',
    'ID' => 57,
    'Name' => '3.1 Fecha Chamado Societario Divergencia Valor do Frete'
  },
  'Activity-85cecd0a202e2ed04fba3e801f8ed524' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-31530c3cd24925fb400dc24f9fc9248d'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-07-14 11:10:05',
    'ID' => 118,
    'Name' => '1. Abertura de Chamado Frete Devolução'
  },
  'Activity-883be8389d2a992ca970e2f72de84273' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-77c8f549920ff4dc040a19ff22a9224e'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-05-04 08:46:20',
    'ID' => 173,
    'Name' => 'Reembolso Circuitos'
  },
  'Activity-88f825a54d5b4267369aaff5d3c7bc2c' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-189c08089f5763a841a9942228fafdf3'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2023-07-03 15:38:52',
    'ID' => 192,
    'Name' => '2. Atendimento Contas Receber Deslocamento'
  },
  'Activity-8a3aa42ee42a35234ffdbcc36f64672b' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-b34a7aec6ff861effc4c8cb228afce9c'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-10-13 11:34:44',
    'ID' => 122,
    'Name' => '2.Atendimento GR'
  },
  'Activity-8b377e12315af97e49188dda2f7cbf33' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-01-21 10:22:42',
    'ID' => 143,
    'Name' => '1.Abertura Chamado Diaria ao Descarregar'
  },
  'Activity-8dd168143b99cbfa342c71d9e94ec60d' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-189c08089f5763a841a9942228fafdf3'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:19:27',
    'ID' => 92,
    'Name' => '1.Abertura Chamado Deslocamento'
  },
  'Activity-8ffcefe41b9f127ce905a85e5a873f22' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-b63401ae0715ef538233f7be338af8b7',
      '2' => 'ActivityDialog-b2e090db08844bc5e0e798c4c762628f'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:18:29',
    'ID' => 85,
    'Name' => '3.Atendimento Societário Diaria Troca de Nota'
  },
  'Activity-908cc1f7b5beda9fcfe0277a80652e5b' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-2360a4eba8574a269cce5ebccdbfa945'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-04 09:41:25',
    'ID' => 150,
    'Name' => '09 - Finalizar Finalização de Remessa'
  },
  'Activity-918256d4a60fb50d325de3bea9b13444' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-b3ab90b93dfe94a87d5bfdeffc3cec0c'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:16:45',
    'ID' => 63,
    'Name' => '2.1 Fechamento Filial'
  },
  'Activity-9289fd2e0184c933551e701205e5fa73' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-f785a9c9168372c236dde3f00a0718ad'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-16 15:13:13',
    'ID' => 164,
    'Name' => '23 - Atendimento Filial Pallet'
  },
  'Activity-94efb1fa28e9876d9b1a9c11625bedb7' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-5b65d9fa9f78d45eb21b49b1d6c0c1c4',
      '2' => 'ActivityDialog-b4a53bd46bdb501919b65fb94c43fed0'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-11-26 11:06:55',
    'ID' => 130,
    'Name' => '2. Atendimento Gestão de Frotas'
  },
  'Activity-95744216ae3bc32970ce501097c47dad' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-380e90623264f051b87cf8a72e538865'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:17:38',
    'ID' => 74,
    'Name' => '3.1 Fecha Chamado Societario Descarga'
  },
  'Activity-959b3c18bb5898f528eb91a9df1e167a' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-e7281b17803a9beb7008dbab2c213026'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:15:17',
    'ID' => 54,
    'Name' => '3.1 Fecha Chamado Societario Frete Bloqueado'
  },
  'Activity-959f74348ab50f357234476d961ea201' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-2360a4eba8574a269cce5ebccdbfa945'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-04 14:21:55',
    'ID' => 154,
    'Name' => '13 - Chamado Encerrado'
  },
  'Activity-96b7da049154684f7619faa15a9ee601' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-2bdd6cd256170f7fabf8137b87e61217'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2019-02-07 17:21:35',
    'ID' => 1,
    'Name' => 'teste'
  },
  'Activity-9a7a81c4d2e7f7ea67d27b0bea5fbb0f' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-d60045da8a265ff06ffa8ea1d47e3d6e'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-07-28 16:55:45',
    'ID' => 187,
    'Name' => 'Cadastro Florestal'
  },
  'Activity-9add24a386bbdc6974e839a70852dd1a' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-c358079ebd217f3b6bac5359d59ac82f'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:18:02',
    'ID' => 78,
    'Name' => '3.1 Fecha Chamado Societario Diario em Posto Fiscal'
  },
  'Activity-9b2083c9a35d2039bdae4854eabdc504' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-1dfdf2ace7d56ac9de1a8c281b309a7a'
    },
    'ChangeTime' => '2025-12-11 14:00:29',
    'CreateTime' => '2025-12-11 13:32:41',
    'ID' => 193,
    'Name' => 'NewKMM - Screen'
  },
  'Activity-9f2eb55cdc07c63039c211ec2fc36749' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-a96ea4e798e67fe9c789f87b8968c048'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:17:06',
    'ID' => 69,
    'Name' => '2.1 Fechamento Filial Diaria no Carregamento'
  },
  'Activity-a81098092f5590fbe7d166a102ab98fe' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-1706111e7d5f598897f915110342d1f0',
      '2' => 'ActivityDialog-b2e090db08844bc5e0e798c4c762628f'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:18:56',
    'ID' => 90,
    'Name' => '3.Atendimento Societário Pedágio'
  },
  'Activity-a84e71cfbdf4179a983b684c95955aec' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-21 10:49:33',
    'ID' => 170,
    'Name' => '28 - Encerrar Chamado'
  },
  'Activity-a93150b729404c9853ff80e42d069fc2' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-2360a4eba8574a269cce5ebccdbfa945'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-04 14:17:54',
    'ID' => 153,
    'Name' => '12 - Finalizar Importação do Canhoto'
  },
  'Activity-ab411f57219f296a861da4c107828340' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-04-06 17:39:13',
    'ID' => 99,
    'Name' => '3.1 Fecha Chamado Societario Pesquisa Motorista'
  },
  'Activity-ab79e7bfe06bfb286094b6b7985f85ca' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-5b65d9fa9f78d45eb21b49b1d6c0c1c4'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-04-07 15:20:00',
    'ID' => 101,
    'Name' => '1.Abertura Chamado Pesquisa Cavalo'
  },
  'Activity-b0c8b5c31975d58c71aee3612e7e7ebf' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-5b65d9fa9f78d45eb21b49b1d6c0c1c4'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-04-07 15:32:06',
    'ID' => 103,
    'Name' => '3.1 Fecha Chamado Societario Pesquisa Cavalo'
  },
  'Activity-b0eb16c0fa3167181bdb76b88ab48c02' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-e9074d0d3c27bd3dade46066f219608c'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-04-08 08:38:34',
    'ID' => 105,
    'Name' => '3.Atendimento Societário Informe de Rendimentos'
  },
  'Activity-b549bda55b80861dd38ac1bb0f0be69c' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-10-25 11:15:26',
    'ID' => 126,
    'Name' => '2. Atendimento Societário Desligamento de Motorista'
  },
  'Activity-b70d5c71c401fc7910610c011c92e237' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-c358079ebd217f3b6bac5359d59ac82f',
      '2' => 'ActivityDialog-b2e090db08844bc5e0e798c4c762628f',
      '3' => 'ActivityDialog-003f712ca1ec4d7465f438f279eed3d4'
    },
    'ChangeTime' => '2026-07-28 10:45:08',
    'CreateTime' => '2021-01-11 15:18:02',
    'ID' => 79,
    'Name' => '2.Atendimento Filial Diaria em Posto Fiscal'
  },
  'Activity-b8d503efb6b866a656c9394a59db1166' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-189c08089f5763a841a9942228fafdf3'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-11-03 10:32:42',
    'ID' => 129,
    'Name' => '3. Atendimento Chamado Deslocamento'
  },
  'Activity-bb60dff927a4068d3b4a6073f04a6ecd' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-003f712ca1ec4d7465f438f279eed3d4'
    },
    'ChangeTime' => '2026-07-28 09:52:29',
    'CreateTime' => '2026-07-28 09:41:38',
    'ID' => 197,
    'Name' => 'valor previsível da estadia'
  },
  'Activity-bda528801e304b6a9df57a0ecc830e7e' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-07 09:19:41',
    'ID' => 160,
    'Name' => '19 - Chamado Encerrado'
  },
  'Activity-bdf29040e889549821aaabfbbda968f4' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-2360a4eba8574a269cce5ebccdbfa945'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-07 13:42:31',
    'ID' => 162,
    'Name' => '21 - Finalizar RPS BRF'
  },
  'Activity-c0346b18fb40af814e11aa762d1ffdc7' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-2360a4eba8574a269cce5ebccdbfa945'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-01-31 15:42:51',
    'ID' => 148,
    'Name' => '06 - Finalizar Emissão de Complemento'
  },
  'Activity-c0f5cc3fceb10bd1f50d0a24a6aed5cb' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-6416899c0870f089522e187fbbe86d92'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-12-17 17:57:22',
    'ID' => 139,
    'Name' => '2.Atendimento Fila Logistica Operacoes'
  },
  'Activity-c21b00a8ee10a1a38833f42cdd7d0966' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-380e90623264f051b87cf8a72e538865',
      '2' => 'ActivityDialog-b2e090db08844bc5e0e798c4c762628f'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:17:38',
    'ID' => 75,
    'Name' => '2.Atendimento Filial Descarga'
  },
  'Activity-c291bd8263ea54f847191586f719c203' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-67c537a7243273883f729c09383753a4'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-07-26 10:00:29',
    'ID' => 181,
    'Name' => 'Abrir chamado Reembolso despesas'
  },
  'Activity-c340d91224f8f03eecabab5b47025ddb' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-2360a4eba8574a269cce5ebccdbfa945'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-04 15:51:44',
    'ID' => 156,
    'Name' => '15 - Finalizar Negociação de Frete'
  },
  'Activity-c3eadf55a512904663b20e95a8ac67f9' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-f7b22bc5326b71e7ac13a3a670af569b',
      '2' => 'ActivityDialog-28e1b7e3b5218ef3176f54cdfc4a3208',
      '3' => 'ActivityDialog-b4a53bd46bdb501919b65fb94c43fed0'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-11-26 14:00:34',
    'ID' => 131,
    'Name' => '3.Atendimento Societário Pesquisa Cavalo'
  },
  'Activity-ca3c4aebe21d59621a4dc56edb2738e5' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-f7b22bc5326b71e7ac13a3a670af569b'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-11-26 14:00:34',
    'ID' => 132,
    'Name' => '3.1 Fecha Chamado Societario Pesquisa Cavalo'
  },
  'Activity-cbb27580a384ca5db1bb0644b6ead582' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-32ba1fe9bcfdbfdff329658a8ad365e9'
    },
    'ChangeTime' => '2026-03-31 11:46:40',
    'CreateTime' => '2026-03-31 11:45:36',
    'ID' => 196,
    'Name' => 'Colocar numero do chamado nstech'
  },
  'Activity-cc846a75b91f3ed31d2291d629dd5a45' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-dc48d1afd0dbd7e535dcd41b26d3a29e',
      '2' => 'ActivityDialog-b2e090db08844bc5e0e798c4c762628f'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:15:43',
    'ID' => 58,
    'Name' => '2.Atendimento Filial Divergencia Valor do Frete'
  },
  'Activity-cd18fec13f3f836de9b2d48b1d776fb5' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-cfd3c4cf72e1ad07a82ab83b5c84a46c'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-03-25 16:46:18',
    'ID' => 93,
    'Name' => '1.Abertura Chamado Reembolso de Imposto Fiscal'
  },
  'Activity-cd3eddb503a7586669ea5110e271bc0e' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-b4a53bd46bdb501919b65fb94c43fed0'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-11-26 16:38:55',
    'ID' => 136,
    'Name' => '2.1 Incluir Campo de Aprovação'
  },
  'Activity-cdd1fbff636742422aeadfbf5904b6e7' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-07 13:47:47',
    'ID' => 163,
    'Name' => '22 - Chamado Encerrado'
  },
  'Activity-cdf77cc0aaa0d4405514d7adb1e56604' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-2de93fb09d400f1d8d30efdc23d96d82'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-07-18 08:46:12',
    'ID' => 176,
    'Name' => '1. Abrir Chamado CRC'
  },
  'Activity-cefe5df7baa4c1a9c6334a3112163dc6' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-10-20 10:46:30',
    'ID' => 124,
    'Name' => '2.Atendimento Societário Retirada de Veículo da Frota'
  },
  'Activity-d0983a8cd2661ae6b10e3ac46ce872b8' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-73235e6148bd7e93806fedced1d7e79b'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-04 14:08:12',
    'ID' => 152,
    'Name' => '11 - Atendimento Filial'
  },
  'Activity-d0c051bf20525a823503926d19151257' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-31530c3cd24925fb400dc24f9fc9248d'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2023-07-03 11:16:36',
    'ID' => 191,
    'Name' => '2. Atendimento Contas Receber Frete Devolução'
  },
  'Activity-d3b95b39c07d64176b57f5e03bb0079b' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-e7281b17803a9beb7008dbab2c213026'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:15:17',
    'ID' => 55,
    'Name' => '2.1 Fechamento Filial Frete Bloqueado'
  },
  'Activity-d476bf12e1684c6763210fe58ae86aac' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-f7b22bc5326b71e7ac13a3a670af569b'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-11-26 14:00:34',
    'ID' => 133,
    'Name' => '1.Abertura Chamado Pesquisa Cavalo'
  },
  'Activity-d58285c33ee48d240f0682dc7815e790' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-b34a7aec6ff861effc4c8cb228afce9c'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-10-13 11:23:35',
    'ID' => 121,
    'Name' => '1.1 Abertura Chamado Reclamações GR'
  },
  'Activity-d6fd78907a8ce6a2d01e61ee6bb82439' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-f7b22bc5326b71e7ac13a3a670af569b',
      '2' => 'ActivityDialog-b4a53bd46bdb501919b65fb94c43fed0'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-11-26 14:00:34',
    'ID' => 134,
    'Name' => '2. Atendimento Gestão de Frotas'
  },
  'Activity-d71a903a9c6dc8a9e52c223bf9b0362f' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-dc48d1afd0dbd7e535dcd41b26d3a29e',
      '2' => 'ActivityDialog-b2e090db08844bc5e0e798c4c762628f'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:15:43',
    'ID' => 59,
    'Name' => '3.Atendimento Societário Divergencia Valor de Frete'
  },
  'Activity-d9eae2e12269e7ead3b5ca4908d003a1' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-aaaff07b1626b48ca1d99827286490fd'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-01-21 10:23:16',
    'ID' => 144,
    'Name' => '1.Abertura Chamado Multa Excesso de Peso'
  },
  'Activity-dc0c29b1887e0302bdb5d79498651c70' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-2360a4eba8574a269cce5ebccdbfa945'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2023-01-04 09:24:07',
    'ID' => 189,
    'Name' => 'Envia TREINAMENTO PDC COOPERADO'
  },
  'Activity-e083e58726f5bb6c1bd0b20ea62b1cc4' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-acb1d3b0ab2d77fa13919847e125945c'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-12-10 10:46:20',
    'ID' => 137,
    'Name' => '01. Abertura de Chamado'
  },
  'Activity-e2a00fa5a6f60667b8a82fc4e2921bab' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-b3ab90b93dfe94a87d5bfdeffc3cec0c'
    },
    'ChangeTime' => '2026-01-20 10:54:40',
    'CreateTime' => '2021-01-11 15:16:45',
    'ID' => 64,
    'Name' => '1.Abertura Chamado Diaria'
  },
  'Activity-e39170cdc2dcc99383d790aad44cf2f7' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-cbbc560d0b7e9c5300109afc16edd094'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-07-01 14:59:35',
    'ID' => 116,
    'Name' => '1.1 Abertura Chamado Liberação de Cursos'
  },
  'Activity-e44e0d34030fe2312558097565bec17d' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-92d8a1697eb85a2cfc436e220093f3f2'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2023-01-04 09:16:03',
    'ID' => 188,
    'Name' => 'Inicia Treinamento PDC Cooperado'
  },
  'Activity-e48af2fade008319bbb0319009a088ef' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-dc48d1afd0dbd7e535dcd41b26d3a29e'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:15:43',
    'ID' => 60,
    'Name' => '1.Abertura Chamado Divergencia Valor do Frete'
  },
  'Activity-e6b5f3828e4455c577f2fa7da9576c91' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-07-27 15:44:25',
    'ID' => 186,
    'Name' => 'Atende Chamado Cadastro Motorista'
  },
  'Activity-ea91cf73f7134ddf0e098e811fe9a0a5' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-5b65d9fa9f78d45eb21b49b1d6c0c1c4',
      '2' => 'ActivityDialog-aadcb869b6fff6aadc09e8e1638dc0d6'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-04-07 15:23:49',
    'ID' => 102,
    'Name' => '3.Atendimento Societário Pesquisa Cavalo'
  },
  'Activity-f23688bdc1a42c66cdd9adeed1f0261b' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-e9074d0d3c27bd3dade46066f219608c'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-04-08 08:32:31',
    'ID' => 104,
    'Name' => '1.Abertura Chamado Informe de Rendimentos'
  },
  'Activity-f26f196baca5bed39288c905c9a061b6' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-01-21 15:49:23',
    'ID' => 147,
    'Name' => '04 - Chamado Encerrado'
  },
  'Activity-f278b2baadc7d88f1b206d3e6a60ef6e' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-2de93fb09d400f1d8d30efdc23d96d82'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-07-18 11:28:14',
    'ID' => 178,
    'Name' => '1. Abrir Chamado Seguro de Vida'
  },
  'Activity-f6038c02aaf7fe99c35832af9e2bcb24' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-09f119af95a3f02d4ca49a9e5784b150'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2019-02-07 17:21:45',
    'ID' => 2,
    'Name' => 'teste'
  },
  'Activity-f65111eb6ee17a37b40d4b2880265e9d' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-2796352615efdd688aefeffb8905c6a1'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-06-09 16:27:00',
    'ID' => 113,
    'Name' => '3.1.Atendimento Societário Voz do Cooperado'
  },
  'Activity-f7676b9a10db3769a97f86ab84db3750' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-2360a4eba8574a269cce5ebccdbfa945'
    },
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-07 09:18:51',
    'ID' => 159,
    'Name' => '18 - Finalizar Quinzena'
  },
  'Activity-f7b065f4de20056ec45fb1072cdfdb9c' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-c358079ebd217f3b6bac5359d59ac82f'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:18:02',
    'ID' => 80,
    'Name' => '2.1 Fechamento Filial Diaria em Posto Fiscal'
  },
  'Activity-f7b946de4dd979529ad56ebff67322b1' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-b3ab90b93dfe94a87d5bfdeffc3cec0c',
      '2' => 'ActivityDialog-aadcb869b6fff6aadc09e8e1638dc0d6',
      '3' => 'ActivityDialog-003f712ca1ec4d7465f438f279eed3d4'
    },
    'ChangeTime' => '2026-07-28 10:44:31',
    'CreateTime' => '2021-01-11 15:16:45',
    'ID' => 65,
    'Name' => '2.Atendimento Filial Diaria ao Descarregar'
  },
  'Activity-fa2f8654fa5ed3e35ca689feddb4d93a' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-7ed7a50997e7643835f144e89bb91e27'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-04-08 10:40:25',
    'ID' => 111,
    'Name' => '3.Atendimento Societário Pesquisa Carreta'
  },
  'Activity-faf71b8f1a4c0e8b18e88ea0333c2053' => {
    'ActivityDialog' => {
      '1' => 'ActivityDialog-a96ea4e798e67fe9c789f87b8968c048',
      '2' => 'ActivityDialog-b2e090db08844bc5e0e798c4c762628f'
    },
    'ChangeTime' => '2025-09-06 14:01:32',
    'CreateTime' => '2021-01-11 15:17:06',
    'ID' => 70,
    'Name' => '3.Atendimento Societário Diaria no Carregamento'
  },
  'Activity-ff4ab46bf4b49d915296cc161e854622' => {
    'ActivityDialog' => '',
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-05-04 10:42:08',
    'ID' => 175,
    'Name' => 'Fechar Chamado Circuitos'
  }
};

$Self->{'Process::ActivityDialog'} = {
  'ActivityDialog-003f712ca1ec4d7465f438f279eed3d4' => {
    'ChangeTime' => '2026-07-28 10:45:47',
    'CreateTime' => '2026-07-28 09:52:01',
    'DescriptionLong' => 'valor previsível da estadia',
    'DescriptionShort' => 'valor previsível da estadia',
    'FieldOrder' => [
      'DynamicField_CoopNestleValorPrevisivelEstadia'
    ],
    'Fields' => {
      'DynamicField_CoopNestleValorPrevisivelEstadia' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Valor Previsível da Estadia',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface'
    ],
    'Name' => 'Adcionar Valor Previsível da Estadia',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Adicionar Valor Previsível da Estadia'
  },
  'ActivityDialog-031edd59d42376b9ffd05018a775a24f' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-04-08 08:39:53',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulario Informe de Rendimentos',
    'FieldOrder' => [
      'CustomerID',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Processo: Informe',
        'Display' => '1'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface'
    ],
    'Name' => 'Formulario Informe de Rendimentos',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-03bf516d8db4f8202abee65a8f24c5ac' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2020-11-23 14:06:04',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulário Anulação',
    'FieldOrder' => [
      'DynamicField_TabelaAnulacao',
      'DynamicField_CteNomePagador',
      'DynamicField_TipoDocumento',
      'DynamicField_Filial',
      'DynamicField_CteSerie',
      'DynamicField_NumeroDocumento',
      'DynamicField_UnidadeNegocio',
      'DynamicField_ValorReceber',
      'DynamicField_CteDataEmissao',
      'CustomerID',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '1'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'processo de exemplo',
        'Display' => '1'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteDataEmissao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNomePagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSerie' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_Filial' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_NumeroDocumento' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_TabelaAnulacao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_TipoDocumento' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_UnidadeNegocio' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ValorReceber' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulário Anulação',
    'Permission' => 'rw',
    'RequiredLock' => '1',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-0582dc208391b0f2a3500d3ebffa6cb6' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-08 10:07:14',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulario teste',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_PesquisaNumeroDocumento'
    ],
    'Fields' => {
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesquisaNumeroDocumento' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario teste',
    'Permission' => '',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Enviar'
  },
  'ActivityDialog-09f119af95a3f02d4ca49a9e5784b150' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2019-02-07 17:22:40',
    'DescriptionLong' => 'Gerar a ata do conselho do controle',
    'DescriptionShort' => 'Gerar ata do conselho',
    'FieldOrder' => [
      'Title',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '0',
          'TimeUnits' => '1'
        },
        'DefaultValue' => '',
        'DescriptionLong' => 'aaa',
        'DescriptionShort' => 'a',
        'Display' => '1'
      },
      'Title' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'aaa',
        'DescriptionShort' => 'aa',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface'
    ],
    'Name' => 'Gerar ata',
    'Permission' => 'create',
    'RequiredLock' => '1',
    'SubmitAdviceText' => 'GERA ATA',
    'SubmitButtonText' => 'GERAR ATA'
  },
  'ActivityDialog-1706111e7d5f598897f915110342d1f0' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-01-11 15:18:56',
    'DescriptionLong' => 'Formulario Pedagio',
    'DescriptionShort' => 'Formulario Pedagio',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_Placa',
      'DynamicField_CteDB',
      'DynamicField_CteFilial',
      'DynamicField_CteFilialNome',
      'DynamicField_CteNumero',
      'DynamicField_CteSerie',
      'DynamicField_CtePlaca',
      'DynamicField_CteCnpjPagador',
      'DynamicField_CteNomePagador',
      'DynamicField_CteDataEmissao',
      'DynamicField_ManifestoNumero',
      'DynamicField_ManifestoData',
      'Article',
      'DynamicField_CteClienteTipoNestle'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Processo: Chamado Pedágio',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteClienteTipoNestle' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteCnpjPagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDB' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteDataEmissao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilial' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilialNome' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNomePagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CtePlaca' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSerie' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoData' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_Placa' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario Pedagio',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-189c08089f5763a841a9942228fafdf3' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-01-11 15:19:27',
    'DescriptionLong' => 'Formulario Deslocamento',
    'DescriptionShort' => 'Formulario Deslocamento',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_Placa',
      'DynamicField_CteDB',
      'DynamicField_CteFilial',
      'DynamicField_CteFilialNome',
      'DynamicField_CteNumero',
      'DynamicField_CteSerie',
      'DynamicField_CtePlaca',
      'DynamicField_CteCnpjPagador',
      'DynamicField_CteNomePagador',
      'DynamicField_CteDataEmissao',
      'DynamicField_ManifestoNumero',
      'DynamicField_ManifestoData',
      'DynamicField_PagoTransportador',
      'DynamicField_CteValor',
      'DynamicField_CteOcorrencia',
      'DynamicField_CteNotaDebitoMarfrig',
      'DynamicField_CteNumeroRegistroBRF',
      'DynamicField_CteCETBRF',
      'DynamicField_CteSenhaBRF',
      'Article',
      'DynamicField_CteClienteTipoNestle'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Processo: Chamado Deslocamento',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteCETBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Somente números são permitidos neste campo e no mínimo 10 dígitos.',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteClienteTipoNestle' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteCnpjPagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDB' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Digitar somente o número do CT-e, exemplo: 100',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteDataEmissao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilial' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilialNome' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNomePagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNotaDebitoMarfrig' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNumeroRegistroBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteOcorrencia' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Preencher somente com números, no mínimo 7 dígitos.',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CtePlaca' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSenhaBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Somente números são permitidos neste campo',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSerie' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteValor' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoData' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_PagoTransportador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_Placa' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Preencher com dados da Placa sem o hífen, ',
        'DescriptionShort' => '',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario Deslocamento',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-1bbe1744824e49a4e4897019e144fb4c' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-04-08 10:09:56',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulario Divergencia Conta Corrente',
    'FieldOrder' => [
      'CustomerID',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Chamado Divergência Conta Corrente',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario Divergencia Conta Corrente',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-1dfdf2ace7d56ac9de1a8c281b309a7a' => {
    'ChangeTime' => '2025-12-11 14:00:43',
    'CreateTime' => '2025-12-11 13:34:27',
    'DescriptionLong' => '',
    'DescriptionShort' => 'NewKMM - Screen',
    'FieldOrder' => [
      'DynamicField_NewKMMTela'
    ],
    'Fields' => {
      'DynamicField_NewKMMTela' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface'
    ],
    'Name' => 'NewKMM - Screen',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-1e7f771b08285cea0537124d9b597e66' => {
    'ChangeTime' => '2026-03-30 09:57:04',
    'CreateTime' => '2021-04-06 17:04:46',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulario Pesquisa Motorista',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_MotoristaNome',
      'DynamicField_MotoristaCPF',
      'DynamicField_MotoristaAnexoCNH',
      'DynamicField_ComprovantePontoCNH',
      'DynamicField_MotoristaAnexoRG',
      'DynamicField_MotoristaAnexoCompResidencia',
      'DynamicField_MotoristaTelefone',
      'DynamicField_MotoristaRef1Nome',
      'DynamicField_MotoristaRef1Parentesco',
      'DynamicField_MotoristaRef1Telefone',
      'DynamicField_MotoristaCavalo',
      'DynamicField_MotoristaCarreta',
      'DynamicField_PesqCliente',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Novo Motorista',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_ComprovantePontoCNH' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_MotoristaAnexoCNH' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_MotoristaAnexoCompResidencia' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_MotoristaAnexoRG' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_MotoristaCPF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_MotoristaCarreta' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_MotoristaCavalo' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_MotoristaNome' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_MotoristaRef1Nome' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_MotoristaRef1Parentesco' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_MotoristaRef1Telefone' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_MotoristaTelefone' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCliente' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario Pesquisa Motorista',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-22c0932c26758c593b257eda069bd35b' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-04-08 09:24:28',
    'DescriptionLong' => 'Formulario Outras Demandas',
    'DescriptionShort' => 'Formulario Outras Demandas',
    'FieldOrder' => [
      'CustomerID',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Processo: Chamado Outras Demandas',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario Outras Demandas',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-2360a4eba8574a269cce5ebccdbfa945' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-01-21 15:50:16',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Encerrar Demanda',
    'FieldOrder' => [
      'CustomerID',
      'Article',
      'DynamicField_EncerrarChamado'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_EncerrarChamado' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Encerrar Demanda',
    'Permission' => '',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-2796352615efdd688aefeffb8905c6a1' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-06-09 16:27:00',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulário Voz do Cooperado',
    'FieldOrder' => [
      'CustomerID',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Processo: Chamado Voz do Cooperado',
        'Display' => '1'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface'
    ],
    'Name' => 'Formulário Voz do Cooperado',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-28e1b7e3b5218ef3176f54cdfc4a3208' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-11-26 14:00:34',
    'DescriptionLong' => 'Etapa onde a Filial ou o Societário vai atender o Chamado, dar um retorno ao Cooperado Transportador.',
    'DescriptionShort' => 'Atividade 2 Atendimento Chamado',
    'FieldOrder' => [
      'DynamicField_CteControleAtividades'
    ],
    'Fields' => {
      'DynamicField_CteControleAtividades' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Controle atividades',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface'
    ],
    'Name' => 'Controle Atendimento Processo',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-291388dba2970dad31b54a925eb9b25f' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'CreateTime' => '2022-07-28 17:02:25',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Cadastro de Placa',
    'FieldOrder' => [
      'DynamicField_TipoVeiculo',
      'DynamicField_Placa',
      'DynamicField_AnexarCRLV',
      'DynamicField_AnexarApoliceSeguro',
      'DynamicField_Antt'
    ],
    'Fields' => {
      'DynamicField_AnexarApoliceSeguro' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_AnexarCRLV' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_Antt' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_Placa' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_TipoVeiculo' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Cadastro de Placa',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-2b59bd12dd05125b348df47f3cd79957' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-01-31 15:15:23',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulário Resposta Emissão de Complemento',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_FilialEmissao',
      'DynamicField_NumeroDocumentoCReceber',
      'DynamicField_CteNumero',
      'DynamicField_CteSerie',
      'DynamicField_TarifaNegociacao',
      'DynamicField_ICMSCte',
      'DynamicField_ValorComplementar',
      'DynamicField_PIS',
      'DynamicField_COFINS',
      'DynamicField_NumeroTransporte'
    ],
    'Fields' => {
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_COFINS' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSerie' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_FilialEmissao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ICMSCte' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_NumeroDocumentoCReceber' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_NumeroTransporte' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_PIS' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_TarifaNegociacao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ValorComplementar' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulário Emissão de Complemento',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => 'Enviar',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-2bdd6cd256170f7fabf8137b87e61217' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-01-31 16:26:18',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Controle Abertura Chamado CReceber',
    'FieldOrder' => [
      'DynamicField_Demanda'
    ],
    'Fields' => {
      'DynamicField_Demanda' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Controle Abertura Chamado CReceber',
    'Permission' => '',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-2de93fb09d400f1d8d30efdc23d96d82' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'CreateTime' => '2022-07-18 08:51:57',
    'DescriptionLong' => '',
    'DescriptionShort' => '1.1 Formulário Seguro de Vida',
    'FieldOrder' => [
      'DynamicField_NomeCooperado',
      'DynamicField_NomeAssegurado',
      'DynamicField_CPFAssegurado',
      'DynamicField_TipoAssegurado',
      'DynamicField_AnexoCnhAssegurado',
      'CustomerID',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Display' => '1'
      },
      'CustomerID' => {
        'Display' => '2'
      },
      'DynamicField_AnexoCnhAssegurado' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CPFAssegurado' => {
        'Display' => '1'
      },
      'DynamicField_NomeAssegurado' => {
        'Display' => '1'
      },
      'DynamicField_NomeCooperado' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_TipoAssegurado' => {
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => '1.1 Formulário Seguro de Vida',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Abrir Chamado'
  },
  'ActivityDialog-3026fd1b4532278e9a23993204d82d5b' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'CreateTime' => '2023-01-26 17:17:22',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulário Diária de Devolução',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_Placa',
      'DynamicField_CteDB',
      'DynamicField_CteFilial',
      'DynamicField_CteFilialNome',
      'DynamicField_CteNumero',
      'DynamicField_CteSerie',
      'DynamicField_CtePlaca',
      'DynamicField_CteCnpjPagador',
      'DynamicField_CteNomePagador',
      'DynamicField_CteDataEmissao',
      'DynamicField_ManifestoNumero',
      'DynamicField_ManifestoData',
      'DynamicField_PagoTransportador',
      'DynamicField_CteValor',
      'DynamicField_CteOcorrencia',
      'DynamicField_CteNumeroRegistroBRF',
      'DynamicField_CteCETBRF',
      'DynamicField_CteSenhaMarfrig',
      'DynamicField_CtedDataHoraChegada',
      'DynamicField_CteDataHoraSaida',
      'Article',
      'DynamicField_CteAnexoPosicaoRastreador',
      'DynamicField_CteDACTECarimbadoAssinado',
      'DynamicField_CteAnexoCETBRF',
      'DynamicField_CteClienteTipoNestle',
      'DynamicField_ViagemSeara'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '0',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Processo: Chamado Diária na Devolução',
        'Display' => '2'
      },
      'CustomerID' => {
        'Display' => '2'
      },
      'DynamicField_CteAnexoCETBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteAnexoPosicaoRastreador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteCETBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteClienteTipoNestle' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteCnpjPagador' => {
        'Display' => '1'
      },
      'DynamicField_CteDACTECarimbadoAssinado' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDB' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Digitar somente o número do CT-e, exemplo: 100',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDataEmissao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDataHoraSaida' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilial' => {
        'Display' => '1'
      },
      'DynamicField_CteFilialNome' => {
        'Display' => '1'
      },
      'DynamicField_CteNomePagador' => {
        'Display' => '1'
      },
      'DynamicField_CteNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNumeroRegistroBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteOcorrencia' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CtePlaca' => {
        'Display' => '1'
      },
      'DynamicField_CteSenhaMarfrig' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSerie' => {
        'Display' => '1'
      },
      'DynamicField_CteValor' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CtedDataHoraChegada' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoData' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoNumero' => {
        'Display' => '1'
      },
      'DynamicField_PagoTransportador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_Placa' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Preencher com dados da Placa sem o hífen, exemplo:ABC1234',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ViagemSeara' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulário Diária de Devolução',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-31530c3cd24925fb400dc24f9fc9248d' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-07-14 11:11:46',
    'DescriptionLong' => 'Formulário Frete Devolução',
    'DescriptionShort' => 'Formulário Frete Devolução',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_Placa',
      'DynamicField_CteDB',
      'DynamicField_CteFilial',
      'DynamicField_CteFilialNome',
      'DynamicField_CteNumero',
      'DynamicField_CteSerie',
      'DynamicField_CtePlaca',
      'DynamicField_CteCnpjPagador',
      'DynamicField_CteNomePagador',
      'DynamicField_CteDataEmissao',
      'DynamicField_ManifestoNumero',
      'DynamicField_PagoTransportador',
      'DynamicField_CteValor',
      'DynamicField_ManifestoData',
      'DynamicField_CteOcorrencia',
      'Article',
      'DynamicField_AnexoCTENF',
      'DynamicField_CteDACTECarimbadoAssinado',
      'DynamicField_CteClienteTipoNestle'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Frete Devolução',
        'Display' => '1'
      },
      'CustomerID' => {
        'Display' => '2'
      },
      'DynamicField_AnexoCTENF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteClienteTipoNestle' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteCnpjPagador' => {
        'Display' => '1'
      },
      'DynamicField_CteDACTECarimbadoAssinado' => {
        'Display' => '1'
      },
      'DynamicField_CteDB' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteDataEmissao' => {
        'Display' => '1'
      },
      'DynamicField_CteFilial' => {
        'Display' => '1'
      },
      'DynamicField_CteFilialNome' => {
        'Display' => '1'
      },
      'DynamicField_CteNomePagador' => {
        'Display' => '1'
      },
      'DynamicField_CteNumero' => {
        'Display' => '1'
      },
      'DynamicField_CteOcorrencia' => {
        'Display' => '1'
      },
      'DynamicField_CtePlaca' => {
        'Display' => '1'
      },
      'DynamicField_CteSerie' => {
        'Display' => '1'
      },
      'DynamicField_CteValor' => {
        'Display' => '1'
      },
      'DynamicField_ManifestoData' => {
        'Display' => '1'
      },
      'DynamicField_ManifestoNumero' => {
        'Display' => '1'
      },
      'DynamicField_PagoTransportador' => {
        'Display' => '1'
      },
      'DynamicField_Placa' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulário Frete Devolução',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-32ba1fe9bcfdbfdff329658a8ad365e9' => {
    'ChangeTime' => '2026-08-06 14:37:40',
    'CreateTime' => '2026-03-31 11:46:24',
    'DescriptionLong' => 'Colocar numero do chamado nstech',
    'DescriptionShort' => 'Colocar numero do chamado nstech',
    'FieldOrder' => [
      'DynamicField_ChamadoNstech',
      'DynamicField_ChamadoNstechQTDCobranca'
    ],
    'Fields' => {
      'DynamicField_ChamadoNstech' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ChamadoNstechQTDCobranca' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface'
    ],
    'Name' => 'Colocar numero do chamado nstech',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-380e90623264f051b87cf8a72e538865' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-01-11 15:17:38',
    'DescriptionLong' => 'Formulario Recibo de Descarga',
    'DescriptionShort' => 'Formulario Recibo de Descarga',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_Placa',
      'DynamicField_CteDB',
      'DynamicField_CteFilial',
      'DynamicField_CteFilialNome',
      'DynamicField_CteNumero',
      'DynamicField_CteSerie',
      'DynamicField_CtePlaca',
      'DynamicField_CteCnpjPagador',
      'DynamicField_CteNomePagador',
      'DynamicField_CteDataEmissao',
      'DynamicField_ManifestoNumero',
      'DynamicField_ManifestoData',
      'DynamicField_PagoTransportador',
      'DynamicField_CteValor',
      'DynamicField_CteOcorrencia',
      'DynamicField_CteSenhaMarfrig',
      'Article',
      'DynamicField_CteDACTENestle',
      'DynamicField_CteAnexoReciboDescarga',
      'DynamicField_AnexoComprovanteEntrega',
      'DynamicField_CteClienteTipoNestle',
      'DynamicField_ViagemSeara'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Processo: Chamado Recibo de Descarga',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_AnexoComprovanteEntrega' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteAnexoReciboDescarga' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteClienteTipoNestle' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteCnpjPagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDACTENestle' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Anexar CTe assinado e carimbado',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDB' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteDataEmissao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilial' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilialNome' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNomePagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteOcorrencia' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CtePlaca' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSenhaMarfrig' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSerie' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteValor' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoData' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_PagoTransportador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_Placa' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_ViagemSeara' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario Recibo de Descarga',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-40ce57d51211544087e15b525e5be531' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'CreateTime' => '2023-05-15 10:13:22',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Importação MultiCTE',
    'FieldOrder' => [
      'DynamicField_MultiCTETipoDocumento',
      'DynamicField_MultiCTEcliente',
      'DynamicField_MultiCTESerie',
      'DynamicField_MultiCTEFilial',
      'DynamicField_MultiCTEAnexoXML',
      'DynamicField_MultiCTEAnexoPDF',
      'DynamicField_MultiCTEDescricao'
    ],
    'Fields' => {
      'DynamicField_MultiCTEAnexoPDF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Anexo PDF',
        'Display' => '2'
      },
      'DynamicField_MultiCTEAnexoXML' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Anexo XML',
        'Display' => '2'
      },
      'DynamicField_MultiCTEDescricao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Descrição',
        'Display' => '2'
      },
      'DynamicField_MultiCTEFilial' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Serie',
        'Display' => '2'
      },
      'DynamicField_MultiCTESerie' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Serie',
        'Display' => '2'
      },
      'DynamicField_MultiCTETipoDocumento' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Tipo do Documento para Baixar',
        'Display' => '2'
      },
      'DynamicField_MultiCTEcliente' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Com a identificação do Cliente podemos saber qual Será o PGR para Download no RODOPAR',
        'DescriptionShort' => 'Cliente do Docuemento',
        'Display' => '2'
      }
    },
    'Interface' => [
      'CustomerInterface'
    ],
    'Name' => 'Formulário Chamado MultiCte',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-4b5130064c75f7c44d14c4c2e0b6897d' => {
    'ChangeTime' => '2025-12-11 14:02:28',
    'CreateTime' => '2025-12-11 14:02:28',
    'DescriptionLong' => '',
    'DescriptionShort' => 'NewKMM - Screen',
    'FieldOrder' => [
      'DynamicField_NewKMMNumCarga'
    ],
    'Fields' => {
      'DynamicField_NewKMMNumCarga' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface'
    ],
    'Name' => 'NewKMM - NumCarga',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-59212aa9c56302096dba93e471d51744' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-07 09:55:15',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Resposta Quinzena',
    'FieldOrder' => [
      'Article',
      'DynamicField_DemandaRealizada'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_DemandaRealizada' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulário Resposta Quinzena',
    'Permission' => '',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Enviar'
  },
  'ActivityDialog-5b65d9fa9f78d45eb21b49b1d6c0c1c4' => {
    'ChangeTime' => '2026-09-16 14:05:21',
    'CreateTime' => '2021-04-07 15:21:55',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulario Pesquisa Cavalo',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_PesqCavalo',
      'DynamicField_PesqCavaloModVeic',
      'DynamicField_PesqCavaloTag',
      'DynamicField_PesqCavaloAnexoCRLV',
      'DynamicField_PesqCavaloAnexoANTT',
      'DynamicField_PesqCavaloAnexoSegTerceiro',
      'DynamicField_PesqCavaloRastreador',
      'DynamicField_PesqCavaloID',
      'DynamicField_ChecklistOperacional1',
      'DynamicField_PesqCavaloPlacaCarreta',
      'DynamicField_PesqCavaloNomeCompleto',
      'DynamicField_PesqCliente',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Pesquisa Cavalo',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_ChecklistOperacional1' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCavalo' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCavaloAnexoANTT' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCavaloAnexoCRLV' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCavaloAnexoSegTerceiro' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCavaloID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCavaloModVeic' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCavaloNomeCompleto' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCavaloPlacaCarreta' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCavaloRastreador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCavaloTag' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCliente' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario Pesquisa Cavalo',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-6416899c0870f089522e187fbbe86d92' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-12-15 14:43:33',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulario Logistica Operacoes',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_ServicoLogistica',
      'DynamicField_DataInicioLogistica',
      'DynamicField_DataFimLogistica',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Logística Operações',
        'Display' => '1'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_DataFimLogistica' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_DataInicioLogistica' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ServicoLogistica' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario Logistica Operacoes',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => 'Criar Chamado',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-64fc80db6895a7958e6a0f4e355da440' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-05-04 08:47:26',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Chamado Reembolso Circuitos',
    'FieldOrder' => [],
    'Fields' => {},
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Reembolso Circuitos',
    'Permission' => '',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-67c537a7243273883f729c09383753a4' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'CreateTime' => '2022-07-26 09:57:10',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulário Reembolso Despesas Conselheiros',
    'FieldOrder' => [
      'DynamicField_NomeCooperado',
      'DynamicField_FotoKMInicial',
      'DynamicField_FotoKMFinal',
      'DynamicField_FotoComprovanteDespesa',
      'DynamicField_DescricaoDespesa'
    ],
    'Fields' => {
      'DynamicField_DescricaoDespesa' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Descrição da Despesa',
        'Display' => '2'
      },
      'DynamicField_FotoComprovanteDespesa' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Comprovante de Despesa',
        'Display' => '2'
      },
      'DynamicField_FotoKMFinal' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Foto do KM Inicial',
        'Display' => '2'
      },
      'DynamicField_FotoKMInicial' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Foto KM Inicial',
        'Display' => '2'
      },
      'DynamicField_NomeCooperado' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Nome Cooperado',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulário Reembolso Despesas Conselheiros',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-73235e6148bd7e93806fedced1d7e79b' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-04 15:15:24',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulário Resposta Importação do Canhoto',
    'FieldOrder' => [
      'CustomerID',
      'Article',
      'DynamicField_DemandaRealizada'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_DemandaRealizada' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulário Resposta Importação do Canhoto',
    'Permission' => '',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Enviar'
  },
  'ActivityDialog-75fc40912458bd40408eb660e0190dd6' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-01-21 15:21:35',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulário Resposta Anulação',
    'FieldOrder' => [
      'DynamicField_CheckList',
      'DynamicField_PCEmissao',
      'DynamicField_PVEmissao',
      'DynamicField_ResponsavelErro',
      'Article',
      'DynamicField_DemandaRealizada'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '1'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CheckList' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_DemandaRealizada' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_PCEmissao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_PVEmissao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ResponsavelErro' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulário Resposta Anulação',
    'Permission' => '',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-77c8f549920ff4dc040a19ff22a9224e' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'CreateTime' => '2022-05-04 08:48:14',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Chamado Reembolso Circuitos',
    'FieldOrder' => [
      'DynamicField_CTeReembolsoCircuitos',
      'DynamicField_PlacaReembolsoCircuitos',
      'DynamicField_ValorReembolsoCircuito',
      'CustomerID',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '2'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CTeReembolsoCircuitos' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PlacaReembolsoCircuitos' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_ValorReembolsoCircuito' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Abre Chamado Reembolso Circuitos',
    'Permission' => '',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-7ed7a50997e7643835f144e89bb91e27' => {
    'ChangeTime' => '2026-03-30 10:39:15',
    'CreateTime' => '2021-04-08 10:40:00',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulario Pesquisa Carreta',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_PesqCarreta',
      'DynamicField_PesqCarretaAnexoCLRV',
      'DynamicField_PesqCarretaTipo',
      'DynamicField_PesqCarretaSegmento',
      'DynamicField_PesqCarretaQntdPalete',
      'DynamicField_PesqCarretaQntdEixo',
      'DynamicField_PesqCarretaPlacaCavalo',
      'DynamicField_PesqCarretaNomeMot',
      'DynamicField_PesqCliente',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Pesquisa Nova Carreta',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCarreta' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCarretaAnexoCLRV' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCarretaNomeMot' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCarretaPlacaCavalo' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCarretaQntdEixo' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCarretaQntdPalete' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCarretaSegmento' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCarretaTipo' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCliente' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario Pesquisa Carreta',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-8393955c0693dfd9ef39d077f11a2377' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'CreateTime' => '2022-07-26 17:15:47',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Termina',
    'FieldOrder' => [
      'DynamicField_EncerrarChamado'
    ],
    'Fields' => {
      'DynamicField_EncerrarChamado' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Encerrar',
        'Display' => '0'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Termina',
    'Permission' => 'move_into',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-92d8a1697eb85a2cfc436e220093f3f2' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'CreateTime' => '2023-01-04 09:22:38',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulário TREINAMENTO PDC COOPERADO',
    'FieldOrder' => [
      'DynamicField_NomeCooperado',
      'DynamicField_CPF',
      'DynamicField_MotoristaAnexoCNH',
      'DynamicField_Assunto'
    ],
    'Fields' => {
      'DynamicField_Assunto' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Assunto',
        'Display' => '2'
      },
      'DynamicField_CPF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_MotoristaAnexoCNH' => {
        'DefaultValue' => 'Anexar Documento',
        'DescriptionLong' => '',
        'DescriptionShort' => 'AnexarCNH/RG',
        'Display' => '2'
      },
      'DynamicField_NomeCooperado' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulário TREINAMENTO PDC COOPERADO',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-9c0366201985d84378ae9505dd0a48a9' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'CreateTime' => '2022-05-05 11:14:43',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Chamado Reembolso Circuitos',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_CTeReembolsoCircuitos',
      'DynamicField_PlacaReembolsoCircuitos',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '0',
          'TimeUnits' => '2'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CTeReembolsoCircuitos' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PlacaReembolsoCircuitos' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface'
    ],
    'Name' => 'Reembolso Circuitos',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-9e087bc4cc4b3e7ceba4e2eb88e8cc79' => {
    'ChangeTime' => '2026-10-14 12:56:45',
    'CreateTime' => '2026-10-14 12:55:44',
    'DescriptionLong' => 'Formulario Diaria no Carregamento',
    'DescriptionShort' => 'Formulario Diaria no Carregamento',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_Placa',
      'DynamicField_CteDB',
      'DynamicField_CteOcorrencia',
      'DynamicField_NotaFiscalCarregamento',
      'DynamicField_CteFilial',
      'DynamicField_CteNumero',
      'DynamicField_CteFilialNome',
      'DynamicField_CteSerie',
      'DynamicField_CtePlaca',
      'DynamicField_CteCnpjPagador',
      'DynamicField_CteNomePagador',
      'DynamicField_CteDataEmissao',
      'DynamicField_ManifestoNumero',
      'DynamicField_ManifestoData',
      'DynamicField_PagoTransportador',
      'DynamicField_CteValor',
      'DynamicField_CteNumeroRegistroBRF',
      'DynamicField_CteCETBRF',
      'DynamicField_CteSenhaBRF',
      'DynamicField_CteSenhaMarfrig',
      'DynamicField_CteAnexoPosicaoRastreador',
      'DynamicField_CteDACTECarimbadoAssinado',
      'DynamicField_CteAnexoCETBRF',
      'DynamicField_CteClienteTipoNestle',
      'DynamicField_ViagemSeara',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'Body' => '',
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '0',
          'StandardTemplateAutoFill' => '0',
          'StandardTemplateID' => [],
          'Subject' => '',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Processo: Chamado Diária No Carregamento',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteAnexoCETBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteAnexoPosicaoRastreador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteCETBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteClienteTipoNestle' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteCnpjPagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDACTECarimbadoAssinado' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDB' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Digitar somente o número do CT-e, exemplo: 100',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDataEmissao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilial' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilialNome' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNomePagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNumeroRegistroBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteOcorrencia' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CtePlaca' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSenhaBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSenhaMarfrig' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSerie' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteValor' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoData' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_NotaFiscalCarregamento' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_PagoTransportador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_Placa' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Preencher com dados da Placa sem o hífen, exemplo:ABC1234',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ViagemSeara' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario Diária no Carregamento',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-a96ea4e798e67fe9c789f87b8968c048' => {
    'ChangeTime' => '2026-10-15 10:30:15',
    'CreateTime' => '2021-01-11 15:17:06',
    'DescriptionLong' => 'Formulario Diaria no Carregamento',
    'DescriptionShort' => 'Formulario Diaria no Carregamento',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_Placa',
      'DynamicField_CteDB',
      'DynamicField_CteFilial',
      'DynamicField_CteFilialNome',
      'DynamicField_CteNumero',
      'DynamicField_CteSerie',
      'DynamicField_CtePlaca',
      'DynamicField_CteCnpjPagador',
      'DynamicField_CteNomePagador',
      'DynamicField_CteDataEmissao',
      'DynamicField_ManifestoNumero',
      'DynamicField_ManifestoData',
      'DynamicField_PagoTransportador',
      'DynamicField_CteValor',
      'DynamicField_CteNumeroRegistroBRF',
      'DynamicField_CteCETBRF',
      'DynamicField_CteSenhaMarfrig',
      'DynamicField_CteAnexoPosicaoRastreador',
      'DynamicField_CteDACTECarimbadoAssinado',
      'DynamicField_CteAnexoCETBRF',
      'DynamicField_CteClienteTipoNestle',
      'DynamicField_CteDACTENestle',
      'DynamicField_ViagemSeara',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Processo: Chamado Diaria No Carregamento',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteAnexoCETBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteAnexoPosicaoRastreador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteCETBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteClienteTipoNestle' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteCnpjPagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDACTECarimbadoAssinado' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDACTENestle' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDB' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Digitar somente o número do CT-e, exemplo: 100',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteDataEmissao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilial' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilialNome' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNomePagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNumeroRegistroBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CtePlaca' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteSenhaMarfrig' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSerie' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteValor' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoData' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_PagoTransportador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_Placa' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Preencher com dados da Placa sem o hífen, exemplo:ABC1234',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_ViagemSeara' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario Diaria no Carregamento',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-aa01d2ea1c3645d0e8a85fbba65c9982' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-21 10:28:50',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulário Resposta Entrega de comprovantes e Protocolos',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_DemandaRealizada',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '1'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_DemandaRealizada' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulário Resposta Entrega de comprovantes e Protocolos',
    'Permission' => '',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Enviar'
  },
  'ActivityDialog-aaaff07b1626b48ca1d99827286490fd' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-01-21 10:27:26',
    'DescriptionLong' => 'Formulario Multa Excesso de Peso',
    'DescriptionShort' => 'Formulario Multa Excesso de Peso',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_Placa',
      'DynamicField_CteDB',
      'DynamicField_CteValor',
      'DynamicField_CteCnpjPagador',
      'DynamicField_CteNomePagador',
      'DynamicField_CteFilial',
      'DynamicField_CteFilialNome',
      'DynamicField_CteSerie',
      'DynamicField_CteNumero',
      'DynamicField_CteDataEmissao',
      'Article',
      'DynamicField_CteAnexoComprovanteMulta'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Multa Excesso de Peso',
        'Display' => '1'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteAnexoComprovanteMulta' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteCnpjPagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDB' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Digitar somente o número do CT-e, exemplo: 100',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteDataEmissao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilial' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilialNome' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNomePagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSerie' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteValor' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_Placa' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Preencher com dados da Placa sem o hífen, ',
        'DescriptionShort' => '',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario Multa Excesso de Peso',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-aadcb869b6fff6aadc09e8e1638dc0d6' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-01-11 15:16:45',
    'DescriptionLong' => 'Etapa onde a Filial ou o Societário vai atender o Chamado, dar um retorno ao Cooperado Transportador.',
    'DescriptionShort' => 'Atividade 2 Atendimento Chamado',
    'FieldOrder' => [
      'DynamicField_CteControleAtividades'
    ],
    'Fields' => {
      'DynamicField_CteControleAtividades' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Controle atividades',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface'
    ],
    'Name' => 'Controle Atendimento Processo',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-acb1d3b0ab2d77fa13919847e125945c' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-12-10 10:48:49',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulário Contas a Receber',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_Demanda',
      'DynamicField_ClientePagadorCReceber',
      'DynamicField_FilialCReceberDB',
      'DynamicField_UnidadeNegocio',
      'DynamicField_FilialEmissao',
      'DynamicField_PesquisaNumeroDocumento',
      'DynamicField_CteSerie',
      'DynamicField_CteNumero',
      'DynamicField_NumeroProtocoloCReceber',
      'DynamicField_CheckListComprovantes',
      'DynamicField_CheckList',
      'DynamicField_CteNomePagador',
      'DynamicField_CteDataEmissao',
      'DynamicField_TipoDocumento',
      'DynamicField_ValorReceber',
      'DynamicField_TarifaNegociacao',
      'DynamicField_MotivoCReceber',
      'DynamicField_ICMSCte',
      'DynamicField_ValorComplementar',
      'DynamicField_PIS',
      'DynamicField_COFINS',
      'DynamicField_NumeroTransporte',
      'DynamicField_OrigemNegociacao',
      'DynamicField_DestinoNegociacao',
      'DynamicField_NumeroCargaCReceber',
      'DynamicField_ComposicaoFreteCReceber',
      'DynamicField_FilialPallet',
      'DynamicField_SeriePallet',
      'DynamicField_CTePallet',
      'DynamicField_NomedoTransportadorPallet',
      'DynamicField_NomedoClientePallet',
      'DynamicField_NumerodoClientePallet',
      'DynamicField_ValoraserDescontadodoTransportadorPallet',
      'DynamicField_FilialdeFaturamentoPallet',
      'DynamicField_Quinzena',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '1'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_COFINS' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CTePallet' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CheckList' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CheckListComprovantes' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ClientePagadorCReceber' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ComposicaoFreteCReceber' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDataEmissao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNomePagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSerie' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_Demanda' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_DestinoNegociacao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_FilialCReceberDB' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_FilialEmissao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_FilialPallet' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_FilialdeFaturamentoPallet' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ICMSCte' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_MotivoCReceber' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_NomedoClientePallet' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_NomedoTransportadorPallet' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_NumeroCargaCReceber' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_NumeroProtocoloCReceber' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_NumeroTransporte' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_NumerodoClientePallet' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_OrigemNegociacao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_PIS' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_PesquisaNumeroDocumento' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_Quinzena' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_SeriePallet' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_TarifaNegociacao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_TipoDocumento' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_UnidadeNegocio' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ValorComplementar' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ValorReceber' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ValoraserDescontadodoTransportadorPallet' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulário Contas a Receber',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Enviar'
  },
  'ActivityDialog-b2e090db08844bc5e0e798c4c762628f' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-01-11 15:15:17',
    'DescriptionLong' => 'Etapa onde a Filial ou o Societário vai atender o Chamado, dar um retorno ao Cooperado Transportador.',
    'DescriptionShort' => 'Atividade 2 Atendimento Chamado',
    'FieldOrder' => [
      'DynamicField_CteControleAtividades'
    ],
    'Fields' => {
      'DynamicField_CteControleAtividades' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Controle atividades',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface'
    ],
    'Name' => 'Controle Atendimento Processo',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-b34a7aec6ff861effc4c8cb228afce9c' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-10-13 11:22:53',
    'DescriptionLong' => 'Formulario Reclamações GR',
    'DescriptionShort' => 'Formulario Reclamações GR',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_GREscolheFornecedor',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Reclamações GR',
        'Display' => '1'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_GREscolheFornecedor' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Escolher Fornecedor:',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario Reclamações GR',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-b3ab90b93dfe94a87d5bfdeffc3cec0c' => {
    'ChangeTime' => '2026-03-05 10:22:54',
    'CreateTime' => '2021-01-11 15:16:45',
    'DescriptionLong' => 'Formulário Diária',
    'DescriptionShort' => 'Formulário Diária',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_Placa',
      'DynamicField_CteDB',
      'DynamicField_CteOcorrencia',
      'DynamicField_CteDACTECarimbadoAssinado',
      'DynamicField_CteAnexoPosicaoRastreador',
      'DynamicField_CteFilial',
      'DynamicField_CteFilialNome',
      'DynamicField_CteNumero',
      'DynamicField_CteSerie',
      'DynamicField_CtePlaca',
      'DynamicField_CteCnpjPagador',
      'DynamicField_CteNomePagador',
      'DynamicField_CteDataEmissao',
      'DynamicField_ManifestoNumero',
      'DynamicField_CteValor',
      'DynamicField_CteNumeroRegistroBRF',
      'DynamicField_CteCETBRF',
      'DynamicField_CteSenhaMarfrig',
      'DynamicField_CteDACTENestle',
      'DynamicField_CteAnexoCETBRF',
      'DynamicField_CteClienteTipoNestle',
      'DynamicField_ViagemSeara',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'Body' => '',
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'StandardTemplateAutoFill' => '0',
          'StandardTemplateID' => [],
          'Subject' => '',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Processo: Chamado Diária ao Descarregar',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteAnexoCETBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'CET BRF',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteAnexoPosicaoRastreador' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Anexar a Posição do Rastreador.',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteCETBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Somente números e no mínimo 10 dígitos.',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteClienteTipoNestle' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteCnpjPagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDACTECarimbadoAssinado' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Conhecimento de Frete Carimbado e Assinado.',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDACTENestle' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Anexar CTe assinado e carimbado',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDB' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Digitar somente o número do CT-e, exemplo: 100',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteDataEmissao' => {
        'Display' => '1'
      },
      'DynamicField_CteFilial' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '3'
      },
      'DynamicField_CteFilialNome' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '3'
      },
      'DynamicField_CteNomePagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNumeroRegistroBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteOcorrencia' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CtePlaca' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Preencher com dados da Placa sem o hífen, exemplo:ABC1234',
        'DescriptionShort' => '',
        'Display' => '3'
      },
      'DynamicField_CteSenhaMarfrig' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSerie' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteValor' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoNumero' => {
        'Display' => '1'
      },
      'DynamicField_Placa' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_ViagemSeara' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulário Diária',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-b4a53bd46bdb501919b65fb94c43fed0' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-11-26 11:37:37',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulário  Controle Atividade Frota',
    'FieldOrder' => [
      'DynamicField_ControleAprovacaoFrota'
    ],
    'Fields' => {
      'DynamicField_ControleAprovacaoFrota' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Controle de Atendimento Frota',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface'
    ],
    'Name' => '2 - Formulário Controle Atividade Frota',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Salvar'
  },
  'ActivityDialog-b63401ae0715ef538233f7be338af8b7' => {
    'ChangeTime' => '2026-02-12 10:59:15',
    'CreateTime' => '2021-01-11 15:18:29',
    'DescriptionLong' => 'Formulario Diária Troca de Nota',
    'DescriptionShort' => 'Formulario Diária Troca de Nota',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_CteOcorrencia',
      'DynamicField_Placa',
      'DynamicField_CteDB',
      'DynamicField_NotaFiscalTroca',
      'DynamicField_CteFilial',
      'DynamicField_CteFilialNome',
      'DynamicField_CteNumero',
      'DynamicField_CteSerie',
      'DynamicField_CtePlaca',
      'DynamicField_CteCnpjPagador',
      'DynamicField_CteNomePagador',
      'DynamicField_CteDataEmissao',
      'DynamicField_ManifestoNumero',
      'DynamicField_ManifestoData',
      'DynamicField_PagoTransportador',
      'DynamicField_CteValor',
      'DynamicField_CteSenhaMarfrig',
      'DynamicField_CteCETBRF',
      'DynamicField_CteAnexoPosicaoRastreador',
      'DynamicField_CteDACTECarimbadoAssinado',
      'DynamicField_CteAnexoCETBRF',
      'DynamicField_CteClienteTipoNestle',
      'DynamicField_ViagemSeara',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Processo: Chamado Diária Troca de Nota',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteAnexoCETBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteAnexoPosicaoRastreador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteCETBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteClienteTipoNestle' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteCnpjPagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDACTECarimbadoAssinado' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDB' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Digitar somente o número do CT-e, exemplo: 100',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteDataEmissao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilial' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilialNome' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNomePagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteOcorrencia' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Preencher somente com números, no mínimo 7 dígitos.',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CtePlaca' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSenhaMarfrig' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSerie' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteValor' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoData' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_NotaFiscalTroca' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PagoTransportador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_Placa' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Preencher com dados da Placa sem o hífen, exemplo:ABC1234',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_ViagemSeara' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario Diária Troca de Nota',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-be5ea986d951a966f0317882df049e6b' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-06-10 09:56:58',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Voz do Cooperado',
    'FieldOrder' => [
      'CustomerID',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Processo: Chamado Voz do Cooperado',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => '1 - Formulário Voz do Cooperado',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-c358079ebd217f3b6bac5359d59ac82f' => {
    'ChangeTime' => '2026-02-23 10:57:27',
    'CreateTime' => '2021-01-11 15:18:02',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulario Diária em Posto Fiscal',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_Placa',
      'DynamicField_CteDB',
      'DynamicField_CteOcorrencia',
      'DynamicField_CTePDF',
      'DynamicField_CteAnexoPosicaoRastreador',
      'DynamicField_CteFilial',
      'DynamicField_CteFilialNome',
      'DynamicField_CteNumero',
      'DynamicField_CteSerie',
      'DynamicField_CtePlaca',
      'DynamicField_CteCnpjPagador',
      'DynamicField_CteNomePagador',
      'DynamicField_CteDataEmissao',
      'DynamicField_ManifestoNumero',
      'DynamicField_ManifestoData',
      'DynamicField_PagoTransportador',
      'DynamicField_CteValor',
      'DynamicField_OC',
      'DynamicField_CteCETBRF',
      'DynamicField_CteDACTECarimbadoAssinado',
      'DynamicField_CteAnexoCETBRF',
      'DynamicField_CteClienteTipoNestle',
      'DynamicField_ViagemSeara',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Processo: Chamado Diária em Posto Fiscal',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CTePDF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteAnexoCETBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteAnexoPosicaoRastreador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteCETBRF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteClienteTipoNestle' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteCnpjPagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDACTECarimbadoAssinado' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDB' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Digitar somente o número do CT-e, exemplo: 100',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteDataEmissao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilial' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilialNome' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNomePagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteOcorrencia' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CtePlaca' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSerie' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteValor' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoData' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_OC' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_PagoTransportador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_Placa' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Preencher com dados da Placa sem o hífen, exemplo:ABC1234',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_ViagemSeara' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario Diária em Posto Fiscal',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-cbbc560d0b7e9c5300109afc16edd094' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-07-01 15:02:29',
    'DescriptionLong' => 'Formulário Liberação Cursos',
    'DescriptionShort' => 'Formulário Liberação Cursos',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_MotoristaNome',
      'DynamicField_LiberaCursos',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => 'Processo: Chamado Libera Cursos',
        'DescriptionShort' => 'Processo: Chamado Libera Cursos',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_LiberaCursos' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Treinamento',
        'Display' => '2'
      },
      'DynamicField_MotoristaNome' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Nome Motorista',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => '1- Formulário Liberação Cursos',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-cfd3c4cf72e1ad07a82ab83b5c84a46c' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-03-25 16:47:41',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Reembolso de Imposto Fiscal',
    'FieldOrder' => [
      'DynamicField_Placa',
      'DynamicField_CteDB',
      'DynamicField_CteFilial',
      'DynamicField_CteFilialNome',
      'DynamicField_CteNumero',
      'DynamicField_CteSerie',
      'DynamicField_CtePlaca',
      'DynamicField_CteCnpjPagador',
      'DynamicField_CteNomePagador',
      'DynamicField_CteDataEmissao',
      'DynamicField_ManifestoNumero',
      'DynamicField_ManifestoData',
      'Article',
      'DynamicField_GuiaImposto',
      'DynamicField_ComprovantePgtoImposto',
      'DynamicField_CteClienteTipoNestle'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Processo Reembolso de Imposto Fiscal',
        'Display' => '2'
      },
      'DynamicField_ComprovantePgtoImposto' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteClienteTipoNestle' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteCnpjPagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDB' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDataEmissao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilial' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilialNome' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNomePagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CtePlaca' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSerie' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_GuiaImposto' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoData' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_Placa' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario Reembolso de Imposto Fiscal',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-d03210c58616d3f4c550c3cdd37ada73' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-01-31 15:59:36',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulário Resposta Emissão Complementar',
    'FieldOrder' => [
      'DynamicField_FilialComplementar',
      'DynamicField_SerieComplementarCReceber',
      'DynamicField_CteComplementar',
      'Article',
      'DynamicField_DemandaRealizada'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteComplementar' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_DemandaRealizada' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_FilialComplementar' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_SerieComplementarCReceber' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface'
    ],
    'Name' => 'Formulário Resposta Emissão Complementar',
    'Permission' => '',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Enviar'
  },
  'ActivityDialog-d60045da8a265ff06ffa8ea1d47e3d6e' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'CreateTime' => '2022-07-27 15:34:31',
    'DescriptionLong' => 'Formulario de cadastro de motorista',
    'DescriptionShort' => 'Formulario de cadastro de motorista',
    'FieldOrder' => [
      'DynamicField_TipoCadastro',
      'DynamicField_TipoVeiculo',
      'DynamicField_MotoristaNome',
      'DynamicField_Telefone',
      'DynamicField_MotoristaAnexoCNH',
      'DynamicField_CPF',
      'DynamicField_Referencia1',
      'DynamicField_TelefoneReferencia',
      'DynamicField_TipoPlaca',
      'DynamicField_AnexarCRLV',
      'DynamicField_AnexarInspecao',
      'DynamicField_AnexarApoliceSeguro'
    ],
    'Fields' => {
      'DynamicField_AnexarApoliceSeguro' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_AnexarCRLV' => {
        'Display' => '1'
      },
      'DynamicField_AnexarInspecao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CPF' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_MotoristaAnexoCNH' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'CNH',
        'Display' => '1'
      },
      'DynamicField_MotoristaNome' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Nome do Motorista',
        'Display' => '1'
      },
      'DynamicField_Referencia1' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_Telefone' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_TelefoneReferencia' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_TipoCadastro' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_TipoPlaca' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_TipoVeiculo' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario de Cadastro de Motorista',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  },
  'ActivityDialog-dadc4cc9b17ac25fac464d2e76d90fdd' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-07 13:50:31',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulário Resposta RPS BRF',
    'FieldOrder' => [
      'DynamicField_NDCReceber',
      'Article',
      'DynamicField_DemandaRealizada'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_DemandaRealizada' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_NDCReceber' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface'
    ],
    'Name' => 'Formulário Resposta RPS BRF',
    'Permission' => '',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Enviar'
  },
  'ActivityDialog-db31612e80e6dda76b3007c68e73c7f8' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-04 10:07:08',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulário Resposta Finalização de Remessa',
    'FieldOrder' => [
      'DynamicField_NumeroRemessaCReceber',
      'Article',
      'DynamicField_DemandaRealizada'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_DemandaRealizada' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_NumeroRemessaCReceber' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulário Resposta Finalização de Remessa',
    'Permission' => '',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Enviar'
  },
  'ActivityDialog-dc48d1afd0dbd7e535dcd41b26d3a29e' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-01-11 15:15:43',
    'DescriptionLong' => 'Formulario Divergencia Valor de Frete',
    'DescriptionShort' => 'Formulario Divergencia Valor de Frete',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_Placa',
      'DynamicField_CteDB',
      'DynamicField_CteFilial',
      'DynamicField_CteFilialNome',
      'DynamicField_CteNumero',
      'DynamicField_CteSerie',
      'DynamicField_CtePlaca',
      'DynamicField_CteCnpjPagador',
      'DynamicField_CteNomePagador',
      'DynamicField_CteDataEmissao',
      'DynamicField_ManifestoNumero',
      'DynamicField_ManifestoData',
      'DynamicField_PagoTransportador',
      'DynamicField_CteValor',
      'Article',
      'DynamicField_CteAnexoPosicaoRastreador',
      'DynamicField_ViagemSeara',
      'DynamicField_CteClienteTipoNestle'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Processo: Chamado Divergência Valor de Frete',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteAnexoPosicaoRastreador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteClienteTipoNestle' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteCnpjPagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDB' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Digitar somente o número do CT-e, exemplo: 100',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteDataEmissao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilial' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilialNome' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNomePagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CtePlaca' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSerie' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteValor' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoData' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_PagoTransportador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_Placa' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Preencher com dados da Placa sem o hífen, exemplo:ABC1234',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_ViagemSeara' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario Divergencia Valor de Frete',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-e3d63df245ec25b32780c3a437d3c07c' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-04 16:25:27',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulário Resposta Negociação de Frete',
    'FieldOrder' => [
      'Article',
      'DynamicField_DemandaRealizada'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_DemandaRealizada' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulário Resposta Negociação de Frete',
    'Permission' => '',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Enviar'
  },
  'ActivityDialog-e7281b17803a9beb7008dbab2c213026' => {
    'ChangeTime' => '2026-08-17 09:14:51',
    'CreateTime' => '2021-01-11 15:15:17',
    'DescriptionLong' => 'Formulario  Frete Bloqueado',
    'DescriptionShort' => 'Formulario  Frete Bloqueado',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_Placa',
      'DynamicField_CteDB',
      'DynamicField_CteFilial',
      'DynamicField_CteFilialNome',
      'DynamicField_CteNumero',
      'DynamicField_CteSerie',
      'DynamicField_CtePlaca',
      'DynamicField_CteCnpjPagador',
      'DynamicField_CteNomePagador',
      'DynamicField_CteClienteTipoNestle',
      'DynamicField_CteDataEmissao',
      'DynamicField_ManifestoNumero',
      'DynamicField_ManifestoData',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Processo: Chamado Frete Bloqueado',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_CteClienteTipoNestle' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteCnpjPagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteDB' => {
        'Display' => '1'
      },
      'DynamicField_CteDataEmissao' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilial' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteFilialNome' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNomePagador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CtePlaca' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_CteSerie' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoData' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_ManifestoNumero' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_Placa' => {
        'DefaultValue' => '',
        'DescriptionLong' => 'Preencher com dados da Placa sem o hífen, exemplo:ABC1234',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario  Frete Bloqueado',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-e9074d0d3c27bd3dade46066f219608c' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-04-08 08:35:38',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulario Informe de Rendimentos',
    'FieldOrder' => [
      'CustomerID',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Processo: Chamado Informe de Rendimentos',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario Informe de Rendimentos',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-f785a9c9168372c236dde3f00a0718ad' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2022-02-16 15:22:22',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulário  Resposta Pallet',
    'FieldOrder' => [
      'DynamicField_PesquisaNumeroDocumento',
      'DynamicField_DemandaRealizada',
      'Article',
      'CustomerID'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '1'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_DemandaRealizada' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      },
      'DynamicField_PesquisaNumeroDocumento' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulário  Resposta Pallet',
    'Permission' => '',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Enviar'
  },
  'ActivityDialog-f7b22bc5326b71e7ac13a3a670af569b' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-11-26 14:00:34',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulario Pesquisa Cavalo',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_PesqCavalo',
      'DynamicField_PesqCavaloAnexoCRLV',
      'DynamicField_PesqCavaloAnexoSegTerceiro',
      'DynamicField_PesqCavaloRastreador',
      'DynamicField_PesqCavaloID',
      'DynamicField_PesqCavaloPlacaCarreta',
      'DynamicField_PesqCavaloNomeCompleto',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Pesquisa Cavalo',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCavalo' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCavaloAnexoCRLV' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCavaloAnexoSegTerceiro' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCavaloID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCavaloNomeCompleto' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCavaloPlacaCarreta' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_PesqCavaloRastreador' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulario Pesquisa Cavalo',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-fa86248da41a0fed937e7ecdac5c2db2' => {
    'ChangeTime' => '2025-09-06 14:01:33',
    'CreateTime' => '2021-10-20 10:26:42',
    'DescriptionLong' => 'Formulário Retirada de Veículo da Frota',
    'DescriptionShort' => 'Formulário Retirada de Veículo da Frota',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_Motivo',
      'DynamicField_Placa',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '0',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => 'Processo: Chamado Retirada de Veículo da Frota',
        'DescriptionShort' => 'Processo: Chamado Retirada de Veículo da Frota',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_Motivo' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_Placa' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => 'Placa',
        'Display' => '2'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => '1 - Formulário Retirada de Veículo da Frota',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => 'Criar Chamado'
  },
  'ActivityDialog-ff022068cf5bb3c6035c468cb3a311b0' => {
    'ChangeTime' => '2026-07-23 14:36:04',
    'CreateTime' => '2021-10-25 11:11:16',
    'DescriptionLong' => '',
    'DescriptionShort' => 'Formulário Desligamento de Motorista',
    'FieldOrder' => [
      'CustomerID',
      'DynamicField_MotoristaNome',
      'Article'
    ],
    'Fields' => {
      'Article' => {
        'Config' => {
          'CommunicationChannel' => 'Internal',
          'IsVisibleForCustomer' => '1',
          'TimeUnits' => '0'
        },
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'CustomerID' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '2'
      },
      'DynamicField_MotoristaNome' => {
        'DefaultValue' => '',
        'DescriptionLong' => '',
        'DescriptionShort' => '',
        'Display' => '1'
      }
    },
    'Interface' => [
      'AgentInterface',
      'CustomerInterface'
    ],
    'Name' => 'Formulário Desligamento de Motorista',
    'Permission' => 'rw',
    'RequiredLock' => '',
    'SubmitAdviceText' => '',
    'SubmitButtonText' => ''
  }
};

$Self->{'Process::Transition'} = {
  'Transition-02c6dc419318b54983e9aee5c4daf0eb' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'Subject' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-04-08 10:11:57',
    'Name' => 'Envia Fila>> Societario Divergencia Conta Corrente'
  },
  'Transition-0491e5279ec69e5fd58521b38287d375' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_CTeReembolsoCircuitos' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2022-05-04 10:39:13',
    'Name' => 'Envia Fila CRC'
  },
  'Transition-08cab4b3491b2c0fc8383778a4224faa' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_MotoristaNome' => {
            'Match' => '.',
            'Type' => 'Module'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-10-25 16:30:13',
    'Name' => 'Ajusta Título'
  },
  'Transition-0d3ed37b5a7a415c46d486a1a2edbf2a' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_GREscolheFornecedor' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-10-13 11:25:27',
    'Name' => 'Envia Fila>> GR'
  },
  'Transition-1ae1477e541a39a8c4d19aeecdcd87ce' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'Subject' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-04-08 09:27:41',
    'Name' => 'Envia Fila>> Societario Outras Demandas'
  },
  'Transition-1f1745ca2265dede7d7e5e82eb47ba7a' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_Demanda' => {
            'Match' => 'Negociação de Frete',
            'Type' => 'String'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2022-02-04 15:44:55',
    'Name' => 'Negociação de Frete'
  },
  'Transition-20182db048c6a754b9dd2d11870ccdfb' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_CteControleAtividades' => {
            'Match' => 'Finalizar Atendimento Societario',
            'Type' => 'String'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-11-26 14:00:34',
    'Name' => 'Fecha Chamado >> Societario Pesquisa Motorista'
  },
  'Transition-218de6a132a88e941a43399579449833' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_EncerrarChamado' => {
            'Match' => 'Aprovar',
            'Type' => 'String'
          },
          'State' => {
            'Match' => 'Aguardando Aprovação',
            'Type' => 'String'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2022-01-21 15:57:54',
    'Name' => 'Encerrar Demanda'
  },
  'Transition-21e17ba120713942188b18d6eb66c8ce' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_NomeAssegurado' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2022-07-18 11:25:15',
    'Name' => '2. Abertura Chamado Seguro de Vida'
  },
  'Transition-24e5fe190fc42ecc7243fb10a21510fc' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_Demanda' => {
            'Match' => 'RPS BRF',
            'Type' => 'String'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2022-02-07 13:41:49',
    'Name' => 'RPS BRF'
  },
  'Transition-275a3d6e70251c3151d53f07ef2cb93f' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'State' => {
            'Match' => 'Aguardando Aprovação',
            'Type' => 'String'
          },
          'dynamicfiled_EncerrarChamado' => {
            'Match' => 'Aprovar',
            'Type' => 'String'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2022-02-18 10:16:55',
    'Name' => 'Encerra Demanda'
  },
  'Transition-2c2ef8468014d00cb8db8ded422cf515' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_MotoristaNome' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-07-01 15:12:50',
    'Name' => 'Envia Fila>> Societario Libera Cursos'
  },
  'Transition-36670ac429deef13254d3e2c5ca12c47' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_ServicoLogistica' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-12-17 17:55:12',
    'Name' => 'Envia Fila>> Logistica Operacoes'
  },
  'Transition-38ba95ab67fdff823560f3dc546eea61' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_CteControleAtividades' => {
            'Match' => 'Finalizar Atendimento Societario',
            'Type' => 'String'
          },
          'DynamicField_CteDB' => {
            'Match' => '.',
            'Type' => 'Regexp'
          },
          'DynamicField_CtePlaca' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-01-11 15:15:17',
    'Name' => 'Fecha Chamado >> Societario'
  },
  'Transition-3beef66bdb6d8b96028744300afa9f27' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'Subject' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-04-08 08:39:48',
    'Name' => 'Envia Fila>> Societario Informe de Rendimentos'
  },
  'Transition-3e5afc39e3984a1074a7dcf6afdbb6de' => {
    'ChangeTime' => '2026-07-30 14:15:43',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_CteClienteTipoNestle' => {
            'Match' => 'NAONESTLE',
            'Type' => 'String'
          },
          'DynamicField_CteDB' => {
            'Match' => '.',
            'Type' => 'Regexp'
          },
          'DynamicField_CtePlaca' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-01-11 15:15:17',
    'Name' => 'Envia Fila>> Societario'
  },
  'Transition-4072a96995c82b274386197fc0d4c0eb' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_Demanda' => {
            'Match' => 'Pallet',
            'Type' => 'String'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2022-02-16 15:18:41',
    'Name' => 'Pallet'
  },
  'Transition-49ddad11678492d672e61adfcb070bde' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'Subject' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-04-08 10:10:49',
    'Name' => 'Envia Fila>> Societario Subjetc 2'
  },
  'Transition-4e50936d9601c4ab72905ce71f3bffb3' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          '<OTRS_TICKET_State>' => {
            'Match' => 'closed successful',
            'Type' => 'String'
          }
        },
        'Type' => 'and'
      },
      '2' => {
        'Fields' => {
          '<OTRS_TICKET_State>' => {
            'Match' => 'pending auto close+',
            'Type' => 'String'
          }
        },
        'Type' => 'or'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2022-07-18 15:11:26',
    'Name' => '4.Encerrar Chamado Seguro de Vida'
  },
  'Transition-5d63750e105ca2b7400da9ac4ff1b951' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_CteClienteTipoNestle' => {
            'Match' => 'CLIENTENAONESTLE',
            'Type' => 'String'
          },
          'DynamicField_CteDB' => {
            'Match' => '.',
            'Type' => 'Regexp'
          },
          'DynamicField_CtePlaca' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-01-11 15:16:45',
    'Name' => 'Envia Fila>> Societario'
  },
  'Transition-607607e2d64c1f941dd0ccc45fa944d8' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_PesqCarreta' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-04-08 10:44:28',
    'Name' => 'Envia Fila>> Societario Pesquisa Carreta'
  },
  'Transition-64b16c29eefa8abf728bfa9e67bc3d3a' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_CteControleAtividades' => {
            'Match' => 'Repasse Societario',
            'Type' => 'String'
          },
          'DynamicField_CteDB' => {
            'Match' => '.',
            'Type' => 'Regexp'
          },
          'DynamicField_CtePlaca' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-01-11 15:16:45',
    'Name' => 'Repassa Fila >> Societario'
  },
  'Transition-67380647ee020f9a24e398a291b12cdd' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'Subject' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-06-10 09:51:27',
    'Name' => 'Envia Fila Qualidade >> Voz do Cooperado'
  },
  'Transition-6c058af18cdb18adbe94bc2913649c6c' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'dynamicfiled_EncerrarChamadoPallet' => {
            'Match' => 'Encerrar Chamado',
            'Type' => 'Module'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2022-02-25 10:49:58',
    'Name' => 'EncerrarChamadoPallet'
  },
  'Transition-798d99f794296ec6a27c8cb8fb17929a' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_CteControleAtividades' => {
            'Match' => 'Finalizar Atendimento Filial',
            'Type' => 'String'
          },
          'DynamicField_CteDB' => {
            'Match' => '.',
            'Type' => 'Regexp'
          },
          'DynamicField_CtePlaca' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-01-11 15:16:45',
    'Name' => 'Fecha Chamado >> Filial'
  },
  'Transition-7c6922530228747f5f007f2afbe209e6' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_Demanda' => {
            'Match' => 'Quinzena',
            'Type' => 'String'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2022-02-07 09:22:52',
    'Name' => 'Quinzena'
  },
  'Transition-801482b55aaeb5e0098d76ac42d85cb9' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_PesqCavalo' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-11-26 14:00:34',
    'Name' => 'Envia Fila>> Gestão de Frota'
  },
  'Transition-80d179e7bf73c3ebd8107625843e3fa5' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_CteControleAtividades' => {
            'Match' => 'Finalizar Atendimento Societario',
            'Type' => 'String'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-04-06 18:07:04',
    'Name' => 'Fecha Chamado >> Societario Pesquisa Motorista'
  },
  'Transition-819b733fbb008f147bc1d473107495b7' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_MotoristaCPF' => {
            'Match' => '.',
            'Type' => 'Regexp'
          },
          'DynamicField_MotoristaNome' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-04-06 17:37:20',
    'Name' => 'Envia Fila>> Societario Pesquisa Motorista'
  },
  'Transition-911980b238486f413d9320e5364479a7' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_Demanda' => {
            'Match' => 'Anulação',
            'Type' => 'String'
          },
          'DynamicField_DemandaRealizada' => {
            'Match' => 'Sim',
            'Type' => 'String'
          }
        },
        'Type' => 'or'
      },
      '2' => {
        'Fields' => {
          'DynamicField_Demanda' => {
            'Match' => 'Emissão de Complementar',
            'Type' => 'String'
          },
          'DynamicField_DemandaRealizada' => {
            'Match' => 'Sim',
            'Type' => 'String'
          }
        },
        'Type' => 'or'
      },
      '3' => {
        'Fields' => {
          'DynamicField_Demanda' => {
            'Match' => 'Finalização de Remessa',
            'Type' => 'String'
          },
          'DynamicField_DemandaRealizada' => {
            'Match' => 'Sim',
            'Type' => 'String'
          }
        },
        'Type' => 'or'
      },
      '4' => {
        'Fields' => {
          'DynamicField_Demanda' => {
            'Match' => 'Importação do Canhoto',
            'Type' => 'String'
          },
          'DynamicField_DemandaRealizada' => {
            'Match' => 'Sim',
            'Type' => 'String'
          }
        },
        'Type' => 'or'
      },
      '5' => {
        'Fields' => {
          'DynamicField_Demanda' => {
            'Match' => 'Negociação de Frete',
            'Type' => 'String'
          },
          'DynamicField_DemandaRealizada' => {
            'Match' => 'Sim',
            'Type' => 'String'
          }
        },
        'Type' => 'or'
      },
      '6' => {
        'Fields' => {
          'DynamicField_Demanda' => {
            'Match' => 'Quinzena',
            'Type' => 'String'
          },
          'DynamicField_DemandaRealizada' => {
            'Match' => 'Sim',
            'Type' => 'String'
          }
        },
        'Type' => 'or'
      },
      '7' => {
        'Fields' => {
          'DynamicField_Demanda' => {
            'Match' => 'RPS BRF',
            'Type' => 'String'
          },
          'DynamicField_DemandaRealizada' => {
            'Match' => 'Sim',
            'Type' => 'String'
          }
        },
        'Type' => 'or'
      },
      '8' => {
        'Fields' => {
          'DynamicField_DemandaRealizada' => {
            'Match' => 'Sim',
            'Type' => 'String'
          },
          'Dynamicfiled_Demanda' => {
            'Match' => 'Pallet',
            'Type' => 'String'
          }
        },
        'Type' => 'or'
      },
      '9' => {
        'Fields' => {
          'DynamicField_DemandaRealizada' => {
            'Match' => 'Sim',
            'Type' => 'String'
          },
          'Dynamicfiled_Demanda' => {
            'Match' => 'Entrega de Comprovantes e Protocolos',
            'Type' => 'String'
          }
        },
        'Type' => 'or'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2022-01-19 15:40:46',
    'Name' => 'Fechar Chamado'
  },
  'Transition-9732d59bce43b339eb81e4870f12f061' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_CteControleAtividades' => {
            'Match' => 'Finalizar Atendimento Filial',
            'Type' => 'String'
          },
          'DynamicField_CteDB' => {
            'Match' => '.',
            'Type' => 'Regexp'
          },
          'DynamicField_CtePlaca' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-01-11 15:15:17',
    'Name' => 'Fecha Chamado >> Filial'
  },
  'Transition-9bacfeaf2c61140c48da0c8e7a424bcc' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'Abre Chamado Reembolso Circuitos' => {
            'Match' => '0',
            'Type' => 'Module'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2022-05-04 08:50:04',
    'Name' => 'Abre Chamado Reembolso Circuitos'
  },
  'Transition-9dd853056049520501b0ec71358b4a42' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'Dynamic_field' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2023-05-15 10:27:30',
    'Name' => 'Envia Fila>>>TI'
  },
  'Transition-a0c40120fa47764c95e3e4a211ca658e' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_EncerrarChamado' => {
            'Match' => 'Reprovar',
            'Type' => 'String'
          },
          'State' => {
            'Match' => 'Aguardando Aprovação',
            'Type' => 'String'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2022-01-29 16:39:24',
    'Name' => 'Reprovado'
  },
  'Transition-a3d7efafe0826c59cd1190e2aedda5e1' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_PesqCavalo' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-04-07 15:22:58',
    'Name' => 'Envia Fila>> Gestao de Frota Pesquisa Cavalo'
  },
  'Transition-a8435f1dc7da1d0d9cb515e135547ced' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'Subject' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-06-09 16:27:00',
    'Name' => 'Envia Fila>> Societario Informe de Rendimentos'
  },
  'Transition-ab5d74c796f2ac79043f3083e5c18563' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_CteControleAtividades' => {
            'Match' => 'Finalizar Atendimento Societario',
            'Type' => 'String'
          },
          'DynamicField_CteDB' => {
            'Match' => '.',
            'Type' => 'Regexp'
          },
          'DynamicField_CtePlaca' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-01-11 15:16:45',
    'Name' => 'Fecha Chamado >> Societario'
  },
  'Transition-ad03af1c27cf330fe8c1dec2a8718f69' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_Placa' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-10-20 10:51:15',
    'Name' => 'Envia Fila>> Societário Retirada do Veículo da Frota'
  },
  'Transition-ae44b839409e478af79f39ab40a6a9fc' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_CteDB' => {
            'Match' => '.',
            'Type' => 'Regexp'
          },
          'DynamicField_Placa' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2022-01-21 11:06:01',
    'Name' => 'Envia Fila>> Societario Multa Excesso de Peso'
  },
  'Transition-b03e4c9acf876a5feb737f89508b0e05' => {
    'ChangeTime' => '2026-07-29 17:38:59',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_MotoristaNome' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-10-25 11:16:21',
    'Name' => 'Envia Fila>> Societário Desligamento de Motorista'
  },
  'Transition-b093d14580a9fd1b1c34fb102222ede9' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_Demanda' => {
            'Match' => 'Anulação',
            'Type' => 'String'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-12-23 17:14:33',
    'Name' => 'Anulação'
  },
  'Transition-b2a2da30b602d0617073d81b7f0ca74d' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_Demanda' => {
            'Match' => 'Importação do Canhoto',
            'Type' => 'String'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2022-02-04 14:09:25',
    'Name' => 'Importação do Canhoto'
  },
  'Transition-b9c1a544b7eb64654903eab6a6244fe8' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_PesqCavalo' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-11-26 16:41:19',
    'Name' => 'Adicionar Campo Aprovação Gestão de Frota Pesquisa Cavalo'
  },
  'Transition-bb4e1bf45c1fbf0374c300c5860c23ef' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_CteClienteTipoNestle' => {
            'Match' => 'NESTLE',
            'Type' => 'String'
          },
          'DynamicField_CteDB' => {
            'Match' => '.',
            'Type' => 'Regexp'
          },
          'DynamicField_CtePlaca' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-01-11 15:16:45',
    'Name' => 'Envia Fila>> Contas Receber'
  },
  'Transition-c1b6046d2b28bafc78d70fca59aefcfd' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_ControleAprovacaoFrota' => {
            'Match' => 'Aprovado',
            'Type' => 'String'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-11-26 14:00:34',
    'Name' => 'Envia Fila>> Societario Pesquisa Cavalo'
  },
  'Transition-ca02f39684e67beff3a33fa35fb6b2f3' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_Demanda' => {
            'Match' => 'Emissão de Complemento',
            'Type' => 'String'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2022-01-18 17:52:11',
    'Name' => 'Emissão de Complemento'
  },
  'Transition-d4d35d84e153167a36f5c9b1b0cdc87f' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_Demanda' => {
            'Match' => 'Aprovação de Faturamento',
            'Type' => 'String'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2022-02-04 09:12:54',
    'Name' => 'Finalização de Remessa'
  },
  'Transition-dabeeff4f023293efdf7550da4c2e102' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_ControleAprovacaoFrota' => {
            'Match' => 'Reprovado',
            'Type' => 'String'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-11-26 14:12:51',
    'Name' => '2 - Fechar Chamado Gestão de Frota'
  },
  'Transition-de296610d52445cc0ba31ee00289a277' => {
    'ChangeTime' => '2025-12-11 13:55:13',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_NewKMMTela' => {
            'Match' => '^(?:Cancelamento de Carga|Carga|Ocorrência|Atendimento)$',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2025-12-11 13:49:38',
    'Name' => 'NewKMM - Trigger Title'
  },
  'Transition-e45bdbd464424ee80f7806a3d2709075' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_CteClienteTipoNestle' => {
            'Match' => 'CLIENTENAONESTLE',
            'Type' => 'String'
          },
          'DynamicField_CteDB' => {
            'Match' => '.',
            'Type' => 'Regexp'
          },
          'DynamicField_CtePlaca' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-07-14 11:44:26',
    'Name' => 'Envia Fila>> Societário Fretes Devolução'
  },
  'Transition-e6aa5f5588a66dbebd492d8b3be5bc53' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_CteControleAtividades' => {
            'Match' => 'Repasse Societario',
            'Type' => 'String'
          },
          'DynamicField_CteDB' => {
            'Match' => '.',
            'Type' => 'Regexp'
          },
          'DynamicField_CtePlaca' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-01-11 15:15:17',
    'Name' => 'Repassa Fila >> Societario'
  },
  'Transition-f6dcf6d1b326a7f5df2f27fca16d89da' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_CteClienteTipoNestle' => {
            'Match' => 'NESTLE',
            'Type' => 'String'
          },
          'DynamicField_CteDB' => {
            'Match' => '.',
            'Type' => 'Regexp'
          },
          'DynamicField_CtePlaca' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-01-11 15:15:17',
    'Name' => 'Envia Fila>> Fila do Contas a Receber'
  },
  'Transition-f8bdf3a5809fa396d66e76482032847a' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_Demanda' => {
            'Match' => 'Entrega de Comprovantes e Protocolos',
            'Type' => 'String'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2022-02-21 10:29:20',
    'Name' => 'Entrega de comprovantes e Protocolos'
  },
  'Transition-fbfe21997a1fae4f3b20af3e7e77a219' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_NomeCooperadoReembolso' => {
            'Match' => '.',
            'Type' => 'Regexp'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2022-07-26 11:34:46',
    'Name' => 'EnviaFilaCRCReembolso'
  },
  'Transition-ff497d895ea7b12616525a4dd47afa64' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Condition' => {
      '1' => {
        'Fields' => {
          'DynamicField_CteControleAtividades' => {
            'Match' => 'Finalizar Atendimento Societario',
            'Type' => 'String'
          }
        },
        'Type' => 'and'
      }
    },
    'ConditionLinking' => 'and',
    'CreateTime' => '2021-04-07 15:33:10',
    'Name' => 'Fecha Chamado >> Societario Pesquisa Cavalo'
  }
};

$Self->{'Process::TransitionAction'} = {
  'TransitionAction-0104186d0be3e519c41230c7b3454ee1' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Contas a Receber::Importação do Canhoto'
    },
    'CreateTime' => '2022-02-04 14:14:51',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Associar ao Serviço Emissão de Canhoto'
  },
  'TransitionAction-0232f81838d66c381da6bb2dd84271dc' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'QUEUE' => 'TI::Sistemas'
    },
    'CreateTime' => '2023-05-15 10:31:06',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila TI'
  },
  'TransitionAction-03d1d295eb3efd9f0b65ae1794a88a8f' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Contas a Receber::Quinzenas'
    },
    'CreateTime' => '2022-02-07 09:47:55',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Associar ao Serviço Quinzena'
  },
  'TransitionAction-04c1a30c2b5358663350a463174d12d9' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Work units' => '1'
    },
    'CreateTime' => '2021-10-27 09:49:40',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::DynamicFieldSet',
    'Name' => 'Atribuir>>Tempo Processo: Chamado Desligamento de Motorista'
  },
  'TransitionAction-050e107607ce4157d8d155d12298af8d' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Processo: Chamado Pesquisa Cavalo'
    },
    'CreateTime' => '2021-11-26 14:00:34',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Servico Processo: Chamado Pesquisa Cavalo'
  },
  'TransitionAction-0546871d3e40be2eb940d6ae4dd7a874' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'OwnerID' => '1'
    },
    'CreateTime' => '2022-02-04 11:07:13',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketOwnerSet',
    'Name' => 'Atribuir Proprietário'
  },
  'TransitionAction-070750085865b64f649fae056a2af695' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'SLA' => 'SLA - Chamado Entrega de comprovantes e Protocolos'
    },
    'CreateTime' => '2022-02-21 10:36:39',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketSLASet',
    'Name' => 'SLA - Chamado Entrega de Comprovantes e Protocolos'
  },
  'TransitionAction-09213ca1fc2cf944b938c96264a0b763' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Title' => 'Motorista: <OTRS_TICKET_DynamicField_MotoristaNome> | Cavalo :<OTRS_TICKET_DynamicField_MotoristaCavalo> |'
    },
    'CreateTime' => '2021-04-07 09:38:00',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Atribui>>Titulo Processo Pesquisa Motorista'
  },
  'TransitionAction-0a74811cba4a49debddb70f4dcbf8d1f' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Service' => 'Processo: Chamado de Deslocamento'
    },
    'CreateTime' => '2021-01-11 15:19:27',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Serviço Processo: Chamado Deslocamento'
  },
  'TransitionAction-0de7f5c2ff4339a44dfed76d039f7983' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Title' => 'Demanda: <OTRS_TICKET_DynamicField_Demanda>   <OTRS_TICKET_DynamicField_FilialEmissao> <OTRS_TICKET_DynamicField_CteSerie> <OTRS_TICKET_DynamicField_CteNumero>'
    },
    'CreateTime' => '2022-02-07 15:42:37',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Título CReceber'
  },
  'TransitionAction-141885eb894dfdd48c1c7c7bdfc6944a' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'DynamicField_FilialEmissao' => '<OTRS_TICKET_DynamicField_TipoDocumento>'
    },
    'CreateTime' => '2022-01-28 10:02:48',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::DynamicFieldSet',
    'Name' => 'Atribuir Valor >> Chamado Fila CReceber'
  },
  'TransitionAction-14265d6d2bcbc40191ebe7595562f39a' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'SLA' => 'SLA - Chamado Importação do Canhoto'
    },
    'CreateTime' => '2022-02-04 14:12:25',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketSLASet',
    'Name' => 'SLA - Chamado Importação do Canhoto'
  },
  'TransitionAction-14ec3df53d33ecef401105ad88d219b7' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'ResponsibleID' => '1'
    },
    'CreateTime' => '2022-02-04 11:01:58',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketResponsibleSet',
    'Name' => 'Atribuir Responsável'
  },
  'TransitionAction-17b92690a7f1793449fe9265ad47e06d' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Title' => 'Placa: <OTRS_TICKET_DynamicField_CtePlaca> | CT-e :<OTRS_TICKET_DynamicField_CteNumero> | Cliente : <OTRS_TICKET_DynamicField_CteNomePagador>'
    },
    'CreateTime' => '2023-07-04 08:47:03',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Atribui>>Titulo Recibo de Descarga'
  },
  'TransitionAction-1b4a33ad97033c50b2430e3e5834fa66' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => 'Qualidade'
    },
    'CreateTime' => '2021-06-09 16:27:00',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila>> Societário Voz do Cooperado'
  },
  'TransitionAction-2209c0ce263f8ccdcca62c24d9e6adb4' => {
    'ChangeTime' => '2025-12-03 15:59:55',
    'Config' => {
      'Service' => 'Processo: Chamado Diária ao Descarregar'
    },
    'CreateTime' => '2021-01-11 15:16:45',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Serviço Processo: Chamado Diária ao Descarregar'
  },
  'TransitionAction-27e3bdab617ac13823e80082ea3ab863' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'SLA' => 'SLA - Chamado Anulação'
    },
    'CreateTime' => '2022-01-12 18:09:07',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketSLASet',
    'Name' => 'Atribuir SLA ao Chamado'
  },
  'TransitionAction-29a034d21e8b87ea76a045840044c88a' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Title' => 'Processo: Chamado Retirada de Veículo da Frota, placa: <OTRS_TICKET_DynamicField_Placa>'
    },
    'CreateTime' => '2021-10-20 11:00:12',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Atribuir>>Titulo Processo: Retirada de Veículo da Frota'
  },
  'TransitionAction-2be8a4ef822b1011e3625fb47304e857' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Logística Operações'
    },
    'CreateTime' => '2021-12-20 09:32:01',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Serviço Processo: Suporte Logistica Operacao'
  },
  'TransitionAction-307189b3d58b1059bcb0918f5fcdee6a' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Contas a Receber::Emissão de Complemento'
    },
    'CreateTime' => '2022-01-18 17:59:48',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => '01.1.3 Atribuir>>Serviço Processo: Chamado Emissão de Complementos'
  },
  'TransitionAction-30dfec830ae45951ee4cdde466c96d17' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'OwnerID' => '1'
    },
    'CreateTime' => '2022-02-07 14:38:18',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketOwnerSet',
    'Name' => 'Atribui Responsável Admin'
  },
  'TransitionAction-312929a5a6f5e2e5a6cfacc3630e5646' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Service' => 'Processo: Chamado Informe de Rendimentos'
    },
    'CreateTime' => '2021-04-08 08:43:57',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Serviço Processo: Chamado Informe de Rendimentos'
  },
  'TransitionAction-32ae8266aed03f86eda026045d026d94' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => 'CRC'
    },
    'CreateTime' => '2021-10-25 11:20:22',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila>> Societário Desligamento de Motorista'
  },
  'TransitionAction-33558b2f71f0f78ae34ea82abe4d411c' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      '<OTRS_TICKET_DynamicField_TabelaAnulacao>' => 'testado'
    },
    'CreateTime' => '2021-10-27 18:04:30',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::DynamicFieldSet',
    'Name' => 'Atribuir>>Tabela: Anulação'
  },
  'TransitionAction-3610c9f0392ce7af5506c2ec19fdecc6' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Processo: Chamado Retirada de Veículo da Frota'
    },
    'CreateTime' => '2021-10-20 10:58:16',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribuir>>Serviço Processo: Chamado Retirada de Veículo da Frota'
  },
  'TransitionAction-39f7b17a45909f37b9808208b1f14d43' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'SLA' => 'SLA - Chamado Finalização Remessa'
    },
    'CreateTime' => '2022-02-04 09:36:45',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketSLASet',
    'Name' => 'SLA - Chamado Finalização de Remessa'
  },
  'TransitionAction-3c62aa9a98549e3d621e211d8e9a0709' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Title' => 'Processo: Chamado Libera Cursos | Motorista: <OTRS_TICKET_DynamicField_MotoristaNome>'
    },
    'CreateTime' => '2021-07-01 15:18:34',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Atribui>>Titulo Processo: Chamado Libera Cursos'
  },
  'TransitionAction-408ddc91189e544c4f3b2b0d96961796' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Title' => 'Chamado Processo <OTRS_TICKET_DynamicField_Demanda>'
    },
    'CreateTime' => '2022-01-29 16:35:16',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Ajusta Titulo >> Processo Chamado CReceber'
  },
  'TransitionAction-416a30e2162623e6372b08f72032295b' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => 'Contas a Pagar'
    },
    'CreateTime' => '2022-02-25 17:22:06',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila Contas a Pagar'
  },
  'TransitionAction-4493e3aa9d49e464cb232315dab10ef6' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => '<OTRS_TICKET_DynamicField_UnidadeNegocio>'
    },
    'CreateTime' => '2022-01-30 13:07:41',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Atribuir Fila Filial'
  },
  'TransitionAction-45202289057e799678781d0f86f4d6e1' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'CRC::Serviço Reembolso de Conselheiros'
    },
    'CreateTime' => '2022-07-26 11:57:00',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Associa Serviço Reembolso Despesas'
  },
  'TransitionAction-455bb02c17e044d4cf0c0123fb0341a6' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'State' => 'open'
    },
    'CreateTime' => '2022-01-30 12:07:19',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketStateSet',
    'Name' => 'Atribuir Estado Aberto'
  },
  'TransitionAction-46d5adf1e08e720d1aef0484e6774e88' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'DynamicField_DemandaRealizada' => 'Não'
    },
    'CreateTime' => '2022-01-30 14:42:37',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::DynamicFieldSet',
    'Name' => 'Ajustar Demanda Realizada>> Chamado Anulação'
  },
  'TransitionAction-48e638cae1ce9e0dbc9705ee4126da26' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'StateID' => '2'
    },
    'CreateTime' => '2021-11-26 14:00:34',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketStateSet',
    'Name' => 'Muda Estado Chamado >> Fechado'
  },
  'TransitionAction-4a5bd970b96b4e6fdd7e44c94a63bec5' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => '<OTRS_TICKET_DynamicField_FilialCReceber>'
    },
    'CreateTime' => '2022-02-07 11:48:28',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila CReceber Suspenso'
  },
  'TransitionAction-4ad6a81896259544f48b7774cb4b2086' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Service' => 'Processo: Chamado Diária Troca de Nota'
    },
    'CreateTime' => '2021-01-11 15:18:29',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Serviço Processo: Chamado Diária Troca de Nota'
  },
  'TransitionAction-4adfb73fb5a3702474ef646b000251ab' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'State' => 'Aguardando Aprovação'
    },
    'CreateTime' => '2022-01-24 16:26:36',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketStateSet',
    'Name' => 'Atribuir Estado Aguardando Aprovação'
  },
  'TransitionAction-4bf6f1bb5effdf01ab49e3cac4ffff94' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'LockID' => '1'
    },
    'CreateTime' => '2022-02-09 09:45:06',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketLockSet',
    'Name' => 'Atribuir Desbloqueio do Ticket'
  },
  'TransitionAction-521177f1cfcf41510677cabc918e23f9' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      '<OTRS_TICKET_DynamicField_MotoristaNome>' => '<OTRS_TICKET_DynamicField_MotoristaNomeDB>'
    },
    'CreateTime' => '2021-10-25 16:01:48',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::DynamicFieldSet',
    'Name' => 'Atribuir>>Nome Motorista Processo: Desligamento de Motorista'
  },
  'TransitionAction-591247449134751f03c3fe287bfc0822' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Service' => 'Processo: Chamado Pesquisa Novo Cavalo'
    },
    'CreateTime' => '2021-04-07 15:25:07',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Servico Processo: Chamado Pesquisa Novo Cavalo'
  },
  'TransitionAction-5d1b7856b97d334757259d4a79d266ea' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Processo: Reembolso Circuitos'
    },
    'CreateTime' => '2022-05-05 11:40:11',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Serviço Reembolso Circuitos CRC'
  },
  'TransitionAction-5e90e23e1c8bcbf147445e881f6998f4' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Queue' => 'CRC'
    },
    'CreateTime' => '2021-01-11 15:16:45',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila>> Societario'
  },
  'TransitionAction-5f8115b756bb2362b9adb9bd34434b55' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Title' => 'Processo: Chamado Outras Demandas'
    },
    'CreateTime' => '2021-04-08 09:30:06',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Atribui>>Titulo Processo Outras Demandas'
  },
  'TransitionAction-60f9f493d562ed11422e6e46a3ae4eb5' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Title' => '<OTRS_TICKET_DynamicField_GREscolheFornecedor> | Proprietário: <OTRS_CUSTOMER_DATA_UserFirstname> <OTRS_CUSTOMER_DATA_UserLastname>'
    },
    'CreateTime' => '2021-10-13 11:40:27',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Atribui>>Titulo Processo Reclamação GR'
  },
  'TransitionAction-63ede623962c067f6c48f5c4c8a75e21' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'SLA' => 'SLA - Chamado Emissão de Complemento'
    },
    'CreateTime' => '2022-01-18 18:06:37',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketSLASet',
    'Name' => '01.1.4 Atribuir>>SLA Processo: Chamado Emissão de Complemento'
  },
  'TransitionAction-64992ddef1ce1debfb1c59fd067b801e' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Title' => 'Placa: <OTRS_TICKET_DynamicField_CtePlaca> | CT-e :<OTRS_TICKET_DynamicField_CteNumero> | Cliente : <OTRS_TICKET_DynamicField_CteNomePagador>'
    },
    'CreateTime' => '2023-09-15 17:46:09',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Atribui>>Titulo Diaria no Carregamento'
  },
  'TransitionAction-675c0fa85a10528965a10b1641d01271' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Title' => 'Placa: <OTRS_TICKET_DynamicField_CtePlaca> | CT-e :<OTRS_TICKET_DynamicField_CteNumero> | Cliente : <OTRS_TICKET_DynamicField_CteNomePagador>'
    },
    'CreateTime' => '2021-01-11 15:15:17',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Atribui>>Titulo Processo'
  },
  'TransitionAction-67ff9abbee698e8ca81cec8f259ee8c7' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Processo: Chamado Desligamento de Motorista'
    },
    'CreateTime' => '2021-10-25 11:25:52',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribuir>>Serviço Processo: Desligamento de Motorista'
  },
  'TransitionAction-68334a2ce8bd1e85c1fdc9d42828d927' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'StateID' => '2'
    },
    'CreateTime' => '2021-01-11 15:16:45',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketStateSet',
    'Name' => 'Muda Estado Chamado >> Fechado'
  },
  'TransitionAction-6d7b7278bd49bf27e044bb60797bdf80' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'DynamicField_EncerrarChamado' => 'Aprovar'
    },
    'CreateTime' => '2022-01-30 16:59:25',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::DynamicFieldSet',
    'Name' => 'Atribuir Encerrar>>: Chamado Fila Contas a Receber - Aprovar'
  },
  'TransitionAction-71bb6b64de549fb494d5571905b40baf' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Title' => 'Informe de Rendimentos'
    },
    'CreateTime' => '2021-04-08 08:43:05',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Atribui>>Titulo Processo Informe de Rendimentos'
  },
  'TransitionAction-73b04a3e1f052eedb131f0bba55b7b01' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => 'Comercial'
    },
    'CreateTime' => '2023-10-16 14:46:07',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila>> Comercial'
  },
  'TransitionAction-73b7a4d7f3493c06344e34dcd4d68bd6' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Service' => 'Processo: Chamado Frete Bloqueado'
    },
    'CreateTime' => '2021-01-11 15:15:17',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Serviço Processo: Chamado Frete Bloqueado'
  },
  'TransitionAction-73f57ad4b0f45b971c0b985e2a43b141' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Title' => 'Voz do Cooperado'
    },
    'CreateTime' => '2021-06-09 16:27:00',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Atribui>>Titulo Processo Voz do Cooperado'
  },
  'TransitionAction-78b47684cb7f8e9bce181b384b4c3c91' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'SLA' => 'SLA - Chamado Negociação de Frete'
    },
    'CreateTime' => '2022-02-04 15:48:40',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketSLASet',
    'Name' => 'SLA - Chamado Negociação de Frete'
  },
  'TransitionAction-7ae0c3bb0a4ecce9f35d5ef3b33a314d' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => 'GR'
    },
    'CreateTime' => '2021-10-13 11:36:33',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Atribui>>Fila GR'
  },
  'TransitionAction-7d9c98651580b36cdc3e279881315b3a' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Contas a Receber::Negociação de Frete'
    },
    'CreateTime' => '2022-02-04 15:47:37',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Associar ao Serviço Negociação de Frete'
  },
  'TransitionAction-7e0f5be36f8a2bcbc4694e51b4f36d47' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Title' => 'Placa: <OTRS_TICKET_DynamicField_CtePlaca> | CT-e :<OTRS_TICKET_DynamicField_CteNumero> | Cliente : <OTRS_TICKET_DynamicField_CteNomePagador>'
    },
    'CreateTime' => '2023-07-03 14:33:21',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Atribui>>Titulo Reembolso de Imposto Fiscal'
  },
  'TransitionAction-7eb0b4a89e9484287fbcde07d352d9ae' => {
    'ChangeTime' => '2025-12-11 13:54:56',
    'Config' => {
      'Title' => '<OTRS_TICKET_DynamicField_NewKMMNumCarga>'
    },
    'CreateTime' => '2025-12-11 13:54:56',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'NewKMM - Change Title'
  },
  'TransitionAction-82e4af68d358b82c6ff035863bcd28e4' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => 'CRC'
    },
    'CreateTime' => '2021-07-16 16:05:51',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila>> Societario Frete Devolucao'
  },
  'TransitionAction-8360d3b5b4073d6841d816a244402560' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'SLA' => 'Sla'
    },
    'CreateTime' => '2022-07-26 14:28:17',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketSLASet',
    'Name' => 'SLA'
  },
  'TransitionAction-85ca04cf2975e6496758edd4db971e39' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Service' => 'Processo: Chamado Pesquisa Novo Motorista'
    },
    'CreateTime' => '2021-04-07 11:38:53',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Serviço Processo: Chamado Pesquisa Novo Motorista'
  },
  'TransitionAction-86abca60af091276d0a0bf3e9fb60182' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'SLA' => 'SLA - Chamado Quinzenas'
    },
    'CreateTime' => '2022-02-07 09:49:52',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketSLASet',
    'Name' => 'SLA - Chamado Quinzena'
  },
  'TransitionAction-874f9fdc07762f17daa5f677f14c4a94' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'SLA' => 'SLA Padrão'
    },
    'CreateTime' => '2022-07-18 11:36:41',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketSLASet',
    'Name' => '2.1 Abrir Chamado Seguro de Vida - SLA'
  },
  'TransitionAction-8880f04868ee17fd8cb37d1e34c4fd42' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Value' => ''
    },
    'CreateTime' => '2022-02-10 15:16:06',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::DynamicFieldSet',
    'Name' => 'Limpa AnexoRetornoCReceber'
  },
  'TransitionAction-88d9974c46daaca24f268f4dc6ac9338' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Queue' => 'Contas a Receber'
    },
    'CreateTime' => '2021-01-11 15:15:17',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila>> Filial do Cte'
  },
  'TransitionAction-8911d4914cd821eb106947a18e124803' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Processo: Chamado Multa Excesso de Peso'
    },
    'CreateTime' => '2022-01-21 11:29:58',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Servico Processo: Chamado Multa Excesso de Peso'
  },
  'TransitionAction-8914367dfd9f4e5aa75c35726a8d2f37' => {
    'ChangeTime' => '2026-01-27 15:19:28',
    'Config' => {
      'ArchiveFlag' => '',
      'Attachments' => '',
      'Body' => '',
      'CommunicationChannel' => '',
      'ContentType' => '',
      'CustomerID' => '',
      'CustomerUser' => '',
      'DynamicField_FieldName' => '',
      'From' => '',
      'HistoryComment' => '',
      'HistoryType' => '',
      'IsVisibleForCustomer' => '',
      'LinkAs' => '',
      'Lock' => '',
      'Owner' => '',
      'PendingTime' => '',
      'PendingTimeDiff' => '',
      'Priority' => '',
      'Queue' => '',
      'Responsible' => '',
      'SLA' => '',
      'SenderType' => '',
      'Service' => '',
      'State' => '',
      'Subject' => '',
      'TimeUnit' => '',
      'Title' => '',
      'Type' => '',
      'UserID' => ''
    },
    'CreateTime' => '2026-01-27 15:19:28',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketCreate',
    'Name' => 'TicketCreate'
  },
  'TransitionAction-8b5fe68cc93169e4e947ef67bbf8b983' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'NomeCooperado' => '<OTRS_CUSTOMER_DATA_UserFirstname> <OTRS_CUSTOMER_DATA_UserLastname>'
    },
    'CreateTime' => '2022-07-18 14:50:13',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::DynamicFieldSet',
    'Name' => '2.5 Abrir Chamado Seguro de Vida - Solicitante'
  },
  'TransitionAction-8c1943e880c49d3ddc89ee5c170c4730' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => '<OTRS_TICKET_DynamicField_UnidadeNegocio>'
    },
    'CreateTime' => '2021-12-23 17:27:54',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Fila Dinamicamente'
  },
  'TransitionAction-8d2e90e8d083cc1db4e4d4f8bc6cee9d' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Processo: Chamado Frete Devolução'
    },
    'CreateTime' => '2021-07-16 11:01:02',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Serviço Processo: Chamado Frete Devolução'
  },
  'TransitionAction-8ea23ab728d824583dc33d2719caaad0' => {
    'ChangeTime' => '2026-01-20 10:55:24',
    'Config' => {
      'Service' => 'Processo: Chamado Diária na Devolução'
    },
    'CreateTime' => '2023-01-26 17:31:08',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Serviço Processo: Chamado Diária na Devolução'
  },
  'TransitionAction-9193a934b4bad0bce8c02912cdbd6977' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Service' => 'Processo: Chamado Reembolso de Imposto Fiscal'
    },
    'CreateTime' => '2021-03-25 17:37:24',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Serviço Processo: Chamado Reembolso de Imposto Fiscal'
  },
  'TransitionAction-91abd1dde98e9edd5cd261862fb6d954' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Service' => 'Processo: Chamado Diária No Carregamento'
    },
    'CreateTime' => '2021-01-11 15:17:06',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Serviço Processo: Chamado Diária No Carregamento'
  },
  'TransitionAction-91e6b6251202637bf56bf6f5579910cb' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Service' => 'Processo: Chamado Pedágio'
    },
    'CreateTime' => '2021-01-11 15:18:56',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Serviço Processo: Chamado Pedágio'
  },
  'TransitionAction-92104974a45f61168b75e46d5ff1fcd7' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'StateID' => '4'
    },
    'CreateTime' => '2021-01-11 15:16:45',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketStateSet',
    'Name' => 'Muda Estado Chamado >> Aberto'
  },
  'TransitionAction-975c5ec99e3b9efa913f26ffb183cd35' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Title' => 'Processo: Chamado Desligamento de Motorista : <OTRS_TICKET_DynamicField_MotoristaNomeDB>'
    },
    'CreateTime' => '2021-10-25 11:22:48',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Atribuir>>Titulo Processo: Desligamento de Motorista'
  },
  'TransitionAction-9b8edf0bb9e4f5e1711758b1b51296e2' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Title' => 'Placa: <OTRS_TICKET_DynamicField_CtePlaca> | CT-e :<OTRS_TICKET_DynamicField_CteNumero> | Cliente : <OTRS_TICKET_DynamicField_CteNomePagador>'
    },
    'CreateTime' => '2022-01-21 11:30:49',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Atribui>>Titulo Processo: Chamado Multa Excesso de Peso'
  },
  'TransitionAction-9c443939314c4b62e16610a28a5f6174' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Processo: Chamado Pesquisa Cavalo'
    },
    'CreateTime' => '2021-11-26 11:57:02',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribuir>>Serviço Processo: Chamado Pesquisa de Motorista'
  },
  'TransitionAction-a1c0ee1faa0d70d54144034283c21753' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'StateID' => '2'
    },
    'CreateTime' => '2022-01-21 16:14:05',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketStateSet',
    'Name' => 'Atribuir Estado Chamado Fechado'
  },
  'TransitionAction-a2a0470400d5dd8f6dba3c04d412060e' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => 'CRC'
    },
    'CreateTime' => '2021-11-26 14:00:34',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila>> Societario Pesquisa Cavalo'
  },
  'TransitionAction-a34d0b5207f266459ed761b79e69e687' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Contas a Receber::Anulação'
    },
    'CreateTime' => '2021-12-23 17:45:22',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Associar ao Serviço Anulação'
  },
  'TransitionAction-aa2281aa9ca6f99710cc25cf43edba4f' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Title' => 'Pesquisa Cavalo : <OTRS_TICKET_DynamicField_PesqCavalo> | Carreta : <OTRS_TICKET_DynamicField_PesqCavaloPlacaCarreta>'
    },
    'CreateTime' => '2021-04-07 15:31:02',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Atribui>>Titulo Processo Pesquisa Cavalo'
  },
  'TransitionAction-ab1aa57420d09aa9f6145541c08ccfa7' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'SLA' => 'SLA Padrão'
    },
    'CreateTime' => '2022-02-25 17:10:48',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketSLASet',
    'Name' => 'SLA Padrão'
  },
  'TransitionAction-abb7107f894d5c4566b5af5c43db8081' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Queue' => 'CRC'
    },
    'CreateTime' => '2021-04-06 17:55:23',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila>> Societario Pesquisa Motorista'
  },
  'TransitionAction-aed5e5e526c60f2a061d4bd591bc7b4a' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Title' => 'Pesquisa Cavalo : <OTRS_TICKET_DynamicField_PesqCavalo> | Carreta : <OTRS_TICKET_DynamicField_PesqCavaloPlacaCarreta>'
    },
    'CreateTime' => '2021-11-26 14:00:34',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Atribui>>Titulo Processo Pesquisa Cavalo'
  },
  'TransitionAction-b00fe4a296e58a8f67cdb4f0d6bfa66b' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Contas a Receber::Entrega de comprovantes e Protocolos'
    },
    'CreateTime' => '2022-02-21 10:37:50',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui Serviço Entrega de Comprovantes e Protocolos'
  },
  'TransitionAction-b1ffefe226fb466a528d0f2f2a3dc9a5' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => 'Gestão de Frota'
    },
    'CreateTime' => '2021-11-26 14:00:34',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila>> Gestão de Frota Pesquisa Cavalo'
  },
  'TransitionAction-b2e244161887a88a00b07c1febb4407c' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'SLA' => 'SLA Padrão'
    },
    'CreateTime' => '2021-10-27 09:37:24',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketSLASet',
    'Name' => 'Atribuir>>SLA Processo: Chamado Desligamento de Motorista'
  },
  'TransitionAction-b2e7d205e1dd516fbd6eeb0c918cbe88' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => 'CRC'
    },
    'CreateTime' => '2021-07-01 15:15:33',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila>> Societario Libera Cursos'
  },
  'TransitionAction-b4684b7534ceb38dcf6ef0005a233259' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => 'CRC'
    },
    'CreateTime' => '2021-10-20 10:56:53',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila>> Societário Retirada do Veículo da Frota'
  },
  'TransitionAction-b874c12595804684c36c4c861c724a1b' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => 'CRC'
    },
    'CreateTime' => '2022-07-18 11:38:09',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => '2.2 Abrir Chamado Seguro de Vida - Fila'
  },
  'TransitionAction-bab9726be4776509fe086e28fb1c1170' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Title' => 'Placa: <OTRS_TICKET_DynamicField_CtePlaca> | CT-e :<OTRS_TICKET_DynamicField_CteNumero> | Cliente : <OTRS_TICKET_DynamicField_CteNomePagador>'
    },
    'CreateTime' => '2021-07-16 16:08:52',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Atribui>>Titulo Processo Frete Devolução'
  },
  'TransitionAction-bcefcaf21bf73bc6451eaf83eac690d1' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'OwnerID' => '<OTRS_TICKET_ResponsibleID>'
    },
    'CreateTime' => '2022-02-07 16:48:13',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketOwnerSet',
    'Name' => 'Atribui Proprietário CReceber'
  },
  'TransitionAction-bfb0f77eacc16ef91094ac33747d6bfc' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => 'CRC'
    },
    'CreateTime' => '2021-11-03 10:43:33',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila>> Societario Chamado Deslocamento'
  },
  'TransitionAction-c132278236aa0f0129b02d989c86bf00' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => 'Contas a Receber'
    },
    'CreateTime' => '2022-01-21 10:50:36',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila CReceber'
  },
  'TransitionAction-c61afa256e989875593bb36b60f59222' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => 'CRC'
    },
    'CreateTime' => '2022-01-21 11:28:23',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Atribui Fila>> Societario Multa Excesso de Peso'
  },
  'TransitionAction-c8c73021d1698951bd81e76dfb330cd2' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'State' => 'open'
    },
    'CreateTime' => '2022-01-30 13:00:48',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketStateSet',
    'Name' => 'Atribuir Estado Aberto'
  },
  'TransitionAction-cb5a26be1396a8bc4da22ab515bd8c9a' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'DynamicField_ControleAprovacaoFrota' => 'Selecione'
    },
    'CreateTime' => '2021-11-26 16:46:22',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::DynamicFieldSet',
    'Name' => 'Atribuir>> Campo Aprovação Gestão de Frota'
  },
  'TransitionAction-cd8bda1518d5a1b9036b1324affedb76' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Queue' => 'CRC'
    },
    'CreateTime' => '2021-01-11 15:15:17',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila>> Societario'
  },
  'TransitionAction-ce6c28a8ce05d632d33168f38c5488f1' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Processo: Chamado Voz do Cooperado'
    },
    'CreateTime' => '2021-06-09 16:27:00',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Serviço Processo: Chamado Voz do Cooperado'
  },
  'TransitionAction-ce8c5627cff1988fb009281bd5abc904' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Queue' => 'CRC'
    },
    'CreateTime' => '2021-04-07 15:28:38',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila>> Societario Pesquisa Cavalo'
  },
  'TransitionAction-d205afacf57879d0b2e36d93dc9f83f9' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'CRC::Seguro de Vida'
    },
    'CreateTime' => '2022-07-18 11:44:04',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => '2.3 Abrir Chamado Seguro de Vida - Serviço'
  },
  'TransitionAction-d6ec2848928ec639ea8ad2df976b313f' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Processo: Chamado Liberação Treinamento'
    },
    'CreateTime' => '2021-07-01 15:16:45',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Serviço Processo: Chamado Libera Cursos'
  },
  'TransitionAction-d8c837018e46b682b1bae8b9eb9b1b89' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'SLA' => 'RPS BRF'
    },
    'CreateTime' => '2022-02-07 13:55:34',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketSLASet',
    'Name' => 'SLA - Chamado RPS BRF'
  },
  'TransitionAction-dad70f041efe7ca0094df405f159afea' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Service' => 'Processo: Chamado Divergência Valor de Frete'
    },
    'CreateTime' => '2021-01-11 15:15:43',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Serviço Processo: Chamado Divergência Valor de Frete'
  },
  'TransitionAction-dae8bd08634b01b4a2090e05f4e4bbac' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Contas a Receber::Anulação'
    },
    'CreateTime' => '2022-01-12 16:37:20',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => '01.1.2 Atribuir>>Serviço Processo: Chamado Anulação'
  },
  'TransitionAction-daee4c43872a8a72e00b4cb39f99f984' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Title' => 'Processo Suporte Logística Operação <OTRS_TICKET_DynamicField_ServicoLogistica>'
    },
    'CreateTime' => '2021-12-20 09:28:11',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Atribui>>Titulo Processo Suporte Logistica Operaçao'
  },
  'TransitionAction-dd378b27493d37e5caa29750249acb44' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'StateID' => '2'
    },
    'CreateTime' => '2021-11-26 14:18:33',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketStateSet',
    'Name' => 'Chamado Fechado Gestão de Frota'
  },
  'TransitionAction-e015aa70d43655427894c238f68378ab' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'GR::Reclamações GR'
    },
    'CreateTime' => '2021-10-13 11:38:11',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Serviço Reclamação GR'
  },
  'TransitionAction-e16d48a9a3906cb66e878764ef4847bc' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Title' => 'Pesquisa Carreta Placa : <OTRS_TICKET_DynamicField_PesqCarreta> | Placa Cavalo : <OTRS_TICKET_DynamicField_PesqCarretaPlacaCavalo>'
    },
    'CreateTime' => '2021-04-08 10:47:08',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Atribui>>Titulo Processo Pesquisa Carreta'
  },
  'TransitionAction-e1d7afada5772cd267cdc544149e3975' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Service' => 'Processo: Chamado Diária em Posto Fiscal'
    },
    'CreateTime' => '2021-01-11 15:18:02',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Serviço Processo: Chamado Diária em Posto Fiscal'
  },
  'TransitionAction-e25af47cb62b3bca4a5fa7864ec01f5e' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Title' => 'Solicitação Seguro de Vida <OTRS_CUSTOMER_DATA_UserFirstname> <OTRS_CUSTOMER_DATA_UserLastname>'
    },
    'CreateTime' => '2022-07-18 11:45:47',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => '2.4 Abrir Chamado Seguro de Vida - Título'
  },
  'TransitionAction-e42829e03eb6793412051227265cb507' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => 'CRC'
    },
    'CreateTime' => '2022-07-27 15:47:56',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila>>CRC1'
  },
  'TransitionAction-e6811d883d754c49b57ec7e39b6d9f17' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Contas a Receber::Pallet'
    },
    'CreateTime' => '2022-02-25 17:09:17',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'AtribuirServicoPallet'
  },
  'TransitionAction-e6a3a3823ddbbec12e54389c12a0f003' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => 'CRC'
    },
    'CreateTime' => '2022-07-26 17:22:46',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Atribuir fila CRC'
  },
  'TransitionAction-e71b81ccf4892ad2d8d0738123ca2c75' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Queue' => 'Contas a Receber'
    },
    'CreateTime' => '2021-01-11 15:16:45',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila>> Contas Receber'
  },
  'TransitionAction-ecd0c9019ae5305b30f586fda49dd3ce' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Queue' => 'CRC'
    },
    'CreateTime' => '2021-04-08 08:41:54',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila>> Societario Informe de Rendimentos'
  },
  'TransitionAction-ef11e06905bcb3ceb65cfb54306121d8' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'StateID' => '2'
    },
    'CreateTime' => '2021-01-11 15:15:17',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketStateSet',
    'Name' => 'Muda Estado Chamado >> Fechado'
  },
  'TransitionAction-f2c0569e2904585f38bc17de50469068' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Contas a Receber::RPS BRF'
    },
    'CreateTime' => '2022-02-07 13:57:28',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribuir>>Serviço Processo: Chamado RPS BRF'
  },
  'TransitionAction-f588eddbc41c73670b1c766301fae776' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Queue' => 'Logística Operações'
    },
    'CreateTime' => '2021-12-20 09:25:33',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Atribui>>Fila Logistica Operacoes'
  },
  'TransitionAction-f76b6001bbd487af656171455d515151' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'Service' => 'Contas a Receber::Finalização de Remessa'
    },
    'CreateTime' => '2022-02-04 09:30:27',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Associar ao Serviço Finalização de Remessa'
  },
  'TransitionAction-fc27eb0b696b7e7d646f0ca3c7864cf8' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Queue' => 'CRC'
    },
    'CreateTime' => '2021-04-08 10:45:08',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketQueueSet',
    'Name' => 'Envia Fila>> Societario Pesquisa Carreta'
  },
  'TransitionAction-fd4c1baba143103fc3b40dbe1ac4b7ba' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Title' => 'Divergência Conta Corrente'
    },
    'CreateTime' => '2021-04-08 10:15:51',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketTitleSet',
    'Name' => 'Atribui>>Titulo Processo Divergencia Conta Corrente'
  },
  'TransitionAction-fd58762a794568d5724cb33aebca187c' => {
    'ChangeTime' => '2025-09-06 14:01:34',
    'Config' => {
      'Service' => 'Processo: Chamado Recibo de Descarga'
    },
    'CreateTime' => '2021-01-11 15:17:38',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::TicketServiceSet',
    'Name' => 'Atribui>>Serviço Processo: Chamado Recibo de Descarga'
  },
  'TransitionAction-fe44f60141582aaa8bbf50ebc232d306' => {
    'ChangeTime' => '2025-09-06 14:01:35',
    'Config' => {
      'DynamicField_EncerrarChamado' => 'Aprovar'
    },
    'CreateTime' => '2022-01-30 14:47:40',
    'Module' => 'Kernel::System::ProcessManagement::TransitionAction::DynamicFieldSet',
    'Name' => 'Ajustar Demanda Encerrar>> Chamado Anulação'
  }
};

    return;
}
1;
