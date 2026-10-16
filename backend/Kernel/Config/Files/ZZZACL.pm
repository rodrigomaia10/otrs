# OTRS config file (automatically generated)
# VERSION:1.1
package Kernel::Config::Files::ZZZACL;
use strict;
use warnings;
no warnings 'redefine'; ## no critic
use utf8;
sub Load {
    my ($File, $Self) = @_;

# Created: 2021-01-11 16:13:31 (samuel.euzebio)
# Changed: 2026-10-15 10:30:54 (rodrigo.maia)
# Comment: 1 - Esconde Campos Chamado - Ativo
$Self->{TicketAcl}->{'1 - Esconde Campos Chamado - Ativo'} = {
  'Possible' => {
    'ShowHide' => {
      'CteDACTECarimbadoAssinado' => [
        '0'
      ],
      'DynamicField_CteAnexoCETBRF' => [
        '0'
      ],
      'DynamicField_CteAnexoPosicaoRastreador' => [
        '0'
      ],
      'DynamicField_CteCETBRF' => [
        '0'
      ],
      'DynamicField_CteClienteTipoNestle' => [
        '0'
      ],
      'DynamicField_CteCnpjPagador' => [
        '3'
      ],
      'DynamicField_CteDACTECarimbadoAssinado' => [
        '3'
      ],
      'DynamicField_CteDACTENestle' => [
        '0'
      ],
      'DynamicField_CteDataEmissao' => [
        '3'
      ],
      'DynamicField_CteFilial' => [
        '3'
      ],
      'DynamicField_CteFilialNome' => [
        '3'
      ],
      'DynamicField_CteNomePagador' => [
        '3'
      ],
      'DynamicField_CteNumero' => [
        '3'
      ],
      'DynamicField_CteOcorrencia' => [
        '2'
      ],
      'DynamicField_CtePlaca' => [
        '3'
      ],
      'DynamicField_CteSenhaMarfrig' => [
        '0'
      ],
      'DynamicField_CteSerie' => [
        '3'
      ],
      'DynamicField_CteValor' => [
        '3'
      ],
      'DynamicField_ManifestoData' => [
        '3'
      ],
      'DynamicField_ManifestoNumero' => [
        '3'
      ],
      'DynamicField_NotaFiscalCarregamento' => [
        '3'
      ],
      'DynamicField_PagoTransportador' => [
        '3'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'Frontend' => {
      'Action' => [
        'AgentTicketProcess',
        'CustomerTicketProcess',
        'NewTicketProcess'
      ]
    },
    'Process' => {
      'ProcessEntityID' => [
        'Process-29d7aad86f50e8197f56341c71c4bf90',
        'Process-f9db7cf70938e64af70a2688bc152d75',
        'Process-646f00304cc7a849fb29520a71c85733',
        'Process-4b491ffe20345a28e32555c19f993a7d',
        'Process-97018c99b310c7426343f6eb090bf6cf',
        'Process-56ca5a2f78e80b672d746c80e1ef0e95',
        'Process-a0a908b48965ce51bc22e44e3e93bb4e',
        'Process-02f4ecb1397d6dc35826527c83b9f199',
        'Process-e8b53c963d58c49c4e762d95a99fb686',
        'Process-cc83c965d123ff5b29595d2329f4edea',
        'Process-f0cadeb17523c1002104bffc80ebe225'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2026-02-05 11:22:52 (diogo.viana)
# Changed: 2026-02-05 14:29:18 (diogo.viana)
# Comment: 1 - Esconde Serviço KMM
$Self->{TicketAcl}->{'1 - Esconde Serviço KMM'} = {
  'Possible' => {},
  'PossibleAdd' => {},
  'PossibleNot' => {
    'Ticket' => {
      'Service' => [
        'TI::Sistemas e Portais::KMM'
      ]
    }
  },
  'Properties' => {
    'CustomerUser' => {
      'Group_rw' => [
        'Filiais'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-09-04 10:39:11 (mikael.oliveira)
# Changed: 2026-01-23 15:01:06 (diogo.viana)
# Comment: 1 - Esconder Campos NewKMM/OldKMM
$Self->{TicketAcl}->{'1 - Esconder Campos NewKMM/OldKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NewKMMCadastro' => [
        '0'
      ],
      'DynamicField_NewKMMCargaEtapas' => [
        '0'
      ],
      'DynamicField_NewKMMCnpjCpf' => [
        '0'
      ],
      'DynamicField_NewKMMErroIntegracao' => [
        '0'
      ],
      'DynamicField_NewKMMEtapa1' => [
        '0'
      ],
      'DynamicField_NewKMMEtapa2' => [
        '0'
      ],
      'DynamicField_NewKMMEtapa3' => [
        '0'
      ],
      'DynamicField_NewKMMEtapa4' => [
        '0'
      ],
      'DynamicField_NewKMMEtapa5' => [
        '0'
      ],
      'DynamicField_NewKMMEtapa6' => [
        '0'
      ],
      'DynamicField_NewKMMEtapa7' => [
        '0'
      ],
      'DynamicField_NewKMMNumCarga' => [
        '0'
      ],
      'DynamicField_NewKMMPlaca' => [
        '0'
      ],
      'DynamicField_OldKMMCaminhoTela' => [
        '0'
      ],
      'DynamicField_OldKMMErro' => [
        '0'
      ],
      'DynamicField_OldKMMUsuario' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {},
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:13:44 (samuel.euzebio)
# Changed: 2026-10-14 15:25:11 (rodrigo.maia)
# Comment: Esconde Anexo Posicao Rastreador HelpDeskTransportado
$Self->{TicketAcl}->{'1- Esconde Anexo Posicao Rastreador HelpDeskTransportador'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteAnexoPosicaoRastreador' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-b3ab90b93dfe94a87d5bfdeffc3cec0c',
        'ActivityDialog-e9eced752f80de08ce7a56dec3b12697',
        'ActivityDialog-a96ea4e798e67fe9c789f87b8968c048',
        'ActivityDialog-e9eced752f80de08ce7a56dec3b12697'
      ],
      'ProcessEntityID' => [
        'Process-29d7aad86f50e8197f56341c71c4bf90',
        'Process-97018c99b310c7426343f6eb090bf6cf',
        'Process-56ca5a2f78e80b672d746c80e1ef0e95',
        'Process-a0a908b48965ce51bc22e44e3e93bb4e'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:13:53 (samuel.euzebio)
# Changed: 2021-11-03 14:48:45 (samuel.euzebio)
# Comment: 1- Esconde Anexo Recibo Descarga
$Self->{TicketAcl}->{'1- Esconde Anexo Recibo Descarga'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_AnexoComprovanteEntrega' => [
        '0'
      ],
      'DynamicField_CteAnexoReciboDescarga' => [
        '0'
      ],
      'DynamicField_CteDACTENestle' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-380e90623264f051b87cf8a72e538865'
      ],
      'ProcessEntityID' => [
        'Process-646f00304cc7a849fb29520a71c85733'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:14:11 (samuel.euzebio)
# Changed: 2021-01-11 16:14:11 (samuel.euzebio)
# Comment: Esconde CET BRF HelpDeskTransportador
$Self->{TicketAcl}->{'1- Esconde CET BRF HelpDeskTransportador'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteAnexoCETBRF' => [
        '0'
      ],
      'DynamicField_CteCETBRF' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-b3ab90b93dfe94a87d5bfdeffc3cec0c',
        'ActivityDialog-c358079ebd217f3b6bac5359d59ac82f',
        'ActivityDialog-b63401ae0715ef538233f7be338af8b7'
      ],
      'ProcessEntityID' => [
        'Process-29d7aad86f50e8197f56341c71c4bf90',
        'Process-97018c99b310c7426343f6eb090bf6cf',
        'Process-a0a908b48965ce51bc22e44e3e93bb4e'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-11-18 15:38:09 (diogo.viana)
# Changed: 2025-11-18 15:45:47 (diogo.viana)
# Comment: 1- Esconde Campos Marketing
$Self->{TicketAcl}->{'1- Esconde Campos Marketing'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_MKTComunicacaoDivulgacao' => [
        '0'
      ],
      'DynamicField_MKTDesenvolvimentoPPT' => [
        '0'
      ],
      'DynamicField_MKTFotografia' => [
        '0'
      ],
      'DynamicField_MKTMateriasDigitais' => [
        '0'
      ],
      'DynamicField_MKTMateriasGraficos' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {},
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:14:33 (samuel.euzebio)
# Changed: 2026-10-14 14:48:07 (rodrigo.maia)
# Comment: Esconde Nota Débito MARFRIG DIÁRIA AO DESCARREGAR
$Self->{TicketAcl}->{'1- Esconde Nota Débito MARFRIG DIÁRIA AO DESCARREGAR'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteNotaDebitoMarfrig' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-645dce235354bf7b59c721b690b9bc4b',
        'ActivityDialog-a96ea4e798e67fe9c789f87b8968c048',
        'ActivityDialog-380e90623264f051b87cf8a72e538865',
        'ActivityDialog-189c08089f5763a841a9942228fafdf3'
      ],
      'ProcessEntityID' => [
        'Process-ffae7f17de2c0db2c5df95bbf3dd281f',
        'Process-56ca5a2f78e80b672d746c80e1ef0e95',
        'Process-646f00304cc7a849fb29520a71c85733',
        'Process-f9db7cf70938e64af70a2688bc152d75'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:14:43 (samuel.euzebio)
# Changed: 2026-10-14 14:47:58 (rodrigo.maia)
# Comment: Esconde Numero Registro BRF  DIÁRIA AO DESCARREGAR
$Self->{TicketAcl}->{'1- Esconde Numero Registro BRF  DIÁRIA AO DESCARREGAR'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteNumeroRegistroBRF' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-645dce235354bf7b59c721b690b9bc4b',
        'ActivityDialog-a96ea4e798e67fe9c789f87b8968c048',
        'ActivityDialog-189c08089f5763a841a9942228fafdf3'
      ],
      'ProcessEntityID' => [
        'Process-ffae7f17de2c0db2c5df95bbf3dd281f',
        'Process-56ca5a2f78e80b672d746c80e1ef0e95',
        'Process-f9db7cf70938e64af70a2688bc152d75'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:15:03 (samuel.euzebio)
# Changed: 2021-01-11 16:15:03 (samuel.euzebio)
# Comment: Esconde Numero Registro BRF HelpDeskTransportador
$Self->{TicketAcl}->{'1- Esconde Numero Registro BRF HelpDeskTransportador'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteNumeroRegistroBRF' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-b3ab90b93dfe94a87d5bfdeffc3cec0c'
      ],
      'ProcessEntityID' => [
        'Process-29d7aad86f50e8197f56341c71c4bf90'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:15:17 (samuel.euzebio)
# Changed: 2026-10-14 14:47:48 (rodrigo.maia)
# Comment: Esconde Senha Marfrig HelpDeskTransportador
$Self->{TicketAcl}->{'1- Esconde Senha Marfrig HelpDeskTransportador'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteSenhaMarfrig' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-645dce235354bf7b59c721b690b9bc4b',
        'ActivityDialog-a96ea4e798e67fe9c789f87b8968c048',
        'ActivityDialog-b3ab90b93dfe94a87d5bfdeffc3cec0c',
        'ActivityDialog-380e90623264f051b87cf8a72e538865'
      ],
      'ProcessEntityID' => [
        'Process-ffae7f17de2c0db2c5df95bbf3dd281f',
        'Process-56ca5a2f78e80b672d746c80e1ef0e95',
        'Process-29d7aad86f50e8197f56341c71c4bf90',
        'Process-646f00304cc7a849fb29520a71c85733'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:15:29 (samuel.euzebio)
# Changed: 2021-01-12 14:39:26 (samuel.euzebio)
# Comment: EscondeCteSenhaBRF Deslocamento
$Self->{TicketAcl}->{'1- EscondeCteSenhaBRF Deslocamento'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteSenhaBRF' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-189c08089f5763a841a9942228fafdf3'
      ],
      'ProcessEntityID' => [
        'Process-f9db7cf70938e64af70a2688bc152d75'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2022-07-18 17:37:37 (rodrigo.maia)
# Changed: 2022-07-19 09:09:40 (rodrigo.maia)
$Self->{TicketAcl}->{'11 - Esconde Campos Seguro de Vida'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_AnexoCnhAssegurado' => [
        '0'
      ],
      'DynamicField_NomeCooperado' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_TipoAssegurado' => [
        '[Not]Motorista',
        '[Not]Motorista  '
      ]
    },
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-2de93fb09d400f1d8d30efdc23d96d82'
      ],
      'ProcessEntityID' => [
        'Process-6ae5ffa9e25e35174f1ef5ab2aaca119'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2022-07-18 17:49:29 (rodrigo.maia)
# Changed: 2022-07-19 08:51:04 (rodrigo.maia)
$Self->{TicketAcl}->{'11 - Mostra Campos Seguro de Vida'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_AnexoCnhAssegurado' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_TipoAssegurado' => [
        'Motorista  ',
        'Motorista'
      ]
    },
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-2de93fb09d400f1d8d30efdc23d96d82'
      ],
      'ProcessEntityID' => [
        'Process-6ae5ffa9e25e35174f1ef5ab2aaca119'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2022-07-19 08:38:20 (rodrigo.maia)
# Changed: 2022-07-19 08:47:13 (rodrigo.maia)
$Self->{TicketAcl}->{'11 - Mostra Nome Solicitante Seguro de Vida'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NomeCooperado' => [
        '1'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'Queue' => {
      'Raw' => [
        'CRC'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2024-04-30 15:54:32 (leonardo.marcal)
# Changed: 2024-04-30 16:02:49 (leonardo.marcal)
# Comment: Esconder se NÃO for RedeSocial, Evento, Comunicado ou Campanha
$Self->{TicketAcl}->{'12- Esconder MKTFormsRede'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_MKTFormsCampanhas' => [
        '0'
      ],
      'DynamicField_MKTFormsComunicados' => [
        '0'
      ],
      'DynamicField_MKTFormsEvento' => [
        '0'
      ],
      'DynamicField_MKTFormsRedeSocial' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_MKTFormsTipoDeArte' => [
        'BRINDES',
        'ADESIVOS',
        'BANNER',
        'FACHADAS',
        'LIVRETO',
        'OUTDOOR',
        'PLACAS'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2024-05-03 10:59:05 (leonardo.marcal)
# Changed: 2024-05-03 10:59:49 (leonardo.marcal)
# Comment: Mostrar quando o tipo de arte for RedeSocial
$Self->{TicketAcl}->{'12- MostrarMKTFormsCampanhas'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_MKTFormsCampanhas' => [
        '2'
      ],
      'DynamicField_MKTFormsComunicados' => [
        '0'
      ],
      'DynamicField_MKTFormsEvento' => [
        '0'
      ],
      'DynamicField_MKTFormsRedeSocial' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_MKTFormsTipoDeArte' => [
        'CAMPANHAS'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2024-05-03 10:54:50 (leonardo.marcal)
# Changed: 2024-05-03 10:58:47 (leonardo.marcal)
# Comment: Mostrar quando o tipo de arte for RedeSocial
$Self->{TicketAcl}->{'12- MostrarMKTFormsComunicados'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_MKTFormsCampanhas' => [
        '0'
      ],
      'DynamicField_MKTFormsComunicados' => [
        '2'
      ],
      'DynamicField_MKTFormsEvento' => [
        '0'
      ],
      'DynamicField_MKTFormsRedeSocial' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_MKTFormsTipoDeArte' => [
        'COMUNICADOS'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2024-05-03 10:54:44 (leonardo.marcal)
# Changed: 2024-05-03 10:57:26 (leonardo.marcal)
# Comment: Mostrar quando o tipo de arte for RedeSocial
$Self->{TicketAcl}->{'12- MostrarMKTFormsEvento'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_MKTFormsCampanhas' => [
        '0'
      ],
      'DynamicField_MKTFormsComunicados' => [
        '0'
      ],
      'DynamicField_MKTFormsEvento' => [
        '2'
      ],
      'DynamicField_MKTFormsRedeSocial' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_MKTFormsTipoDeArte' => [
        'EVENTO'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2024-04-30 15:24:31 (leonardo.marcal)
# Changed: 2024-04-30 15:51:33 (leonardo.marcal)
# Comment: Mostrar quando o tipo de arte for RedeSocial
$Self->{TicketAcl}->{'12- MostrarMKTFormsRedeSocial'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_MKTFormsComunicados' => [
        '0'
      ],
      'DynamicField_MKTFormsEvento' => [
        '0'
      ],
      'DynamicField_MKTFormsRedeSocial' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_MKTFormsTipoDeArte' => [
        'REDE SOCIAL'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2026-04-13 15:31:54 (diogo.viana)
# Changed: 2026-04-13 15:36:19 (diogo.viana)
$Self->{TicketAcl}->{'1Hide FichaMatricula'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CodCGCCnpj' => [
        '0'
      ],
      'DynamicField_CodCPF' => [
        '0'
      ],
      'DynamicField_FichaMatriculaAnexoContratoSocial' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {},
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2026-03-27 16:38:09 (diogo.viana)
# Changed: 2026-03-27 16:47:01 (diogo.viana)
$Self->{TicketAcl}->{'1Hide TIInfraNewEmployee'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_TIInfraNewEmployeeCostCenter' => [
        '0'
      ],
      'DynamicField_TIInfraNewEmployeeEmailGroups' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {},
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-10-29 10:27:25 (rodrigo.maia)
# Changed: 2021-11-03 10:25:07 (samuel.euzebio)
# Comment: 2 - Mostra Anexo Comprovante de Entrega
$Self->{TicketAcl}->{'2 - Mostra Anexo Comprovante de Entrega - Recibo de Descarga'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_AnexoComprovanteEntrega' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_CteNomePagador' => [
        'FINI',
        'M DIAS BRANCO',
        'GENOMMA'
      ]
    },
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-380e90623264f051b87cf8a72e538865'
      ],
      'ProcessEntityID' => [
        'Process-646f00304cc7a849fb29520a71c85733'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-12-15 10:58:22 (diogo.viana)
# Changed: 2025-12-15 11:00:58 (diogo.viana)
# Comment: 2 - Mostra CNPJ / CPF NewKMM
$Self->{TicketAcl}->{'2 - Mostra CNPJ / CPF NewKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NewKMMCnpjCpf' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_NewKMMCadastro' => [
        'Motorista',
        'Pessoa'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2026-01-22 15:53:07 (diogo.viana)
# Changed: 2026-01-22 15:57:09 (diogo.viana)
# Comment: 2 - Mostra CNPJ / CPF OldKMM
$Self->{TicketAcl}->{'2 - Mostra CNPJ / CPF OldKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NewKMMCnpjCpf' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_OldKMMTela' => [
        'Motoristas',
        'Pessoas'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-12-15 10:27:24 (diogo.viana)
# Changed: 2025-12-15 10:28:53 (diogo.viana)
# Comment: 2 - Mostra Cadastro NewKMM
$Self->{TicketAcl}->{'2 - Mostra Cadastro NewKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NewKMMCadastro' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_NewKMMTela' => [
        'Cadastro'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2026-01-23 15:09:13 (diogo.viana)
# Changed: 2026-01-23 15:11:18 (diogo.viana)
$Self->{TicketAcl}->{'2 - Mostra Campos Caminho da Tela OldKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_OldKMMCaminhoTela' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_OldKMMTela' => [
        'Liberação de Tela'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-09-04 10:55:23 (mikael.oliveira)
# Changed: 2025-12-11 15:26:47 (diogo.viana)
$Self->{TicketAcl}->{'2 - Mostra Campos Etapa 3 NewKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NewKMMEtapa3' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_NewKMMCargaEtapas' => [
        '3'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-09-04 11:10:14 (mikael.oliveira)
# Changed: 2025-12-11 15:26:54 (diogo.viana)
$Self->{TicketAcl}->{'2 - Mostra Campos Etapa 4 NewKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NewKMMErroIntegracao' => [
        '2'
      ],
      'DynamicField_NewKMMEtapa4' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_NewKMMCargaEtapas' => [
        '4'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-09-04 11:23:45 (mikael.oliveira)
# Changed: 2025-12-11 15:27:01 (diogo.viana)
$Self->{TicketAcl}->{'2 - Mostra Campos Etapa 5 NewKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NewKMMErroIntegracao' => [
        '2'
      ],
      'DynamicField_NewKMMEtapa5' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_NewKMMCargaEtapas' => [
        '5'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-09-04 11:29:26 (mikael.oliveira)
# Changed: 2025-12-11 15:27:10 (diogo.viana)
$Self->{TicketAcl}->{'2 - Mostra Campos Etapa 6 NewKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NewKMMErroIntegracao' => [
        '2'
      ],
      'DynamicField_NewKMMEtapa6' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_NewKMMCargaEtapas' => [
        '6'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-09-04 11:31:10 (mikael.oliveira)
# Changed: 2025-12-11 15:27:18 (diogo.viana)
$Self->{TicketAcl}->{'2 - Mostra Campos Etapa 7 NewKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NewKMMEtapa7' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_NewKMMCargaEtapas' => [
        '7'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2026-01-23 15:03:34 (diogo.viana)
# Changed: 2026-01-23 15:06:18 (diogo.viana)
$Self->{TicketAcl}->{'2 - Mostra Campos Usuário OldKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_OldKMMUsuario' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_OldKMMTela' => [
        'Cadastro e Liberação de Usuário',
        'Liberação de Tela'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-11-18 15:52:18 (diogo.viana)
# Changed: 2025-11-18 17:33:23 (diogo.viana)
# Comment: 2 - Mostra Comunicacao Marketing
$Self->{TicketAcl}->{'2 - Mostra Comunicacao Marketing'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_MKTComunicacaoDivulgacao' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_MKTMateriasComunicacao' => [
        'Comunicação ou Divulgação'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-11-18 18:18:14 (diogo.viana)
# Changed: 2025-11-18 18:21:29 (diogo.viana)
# Comment: 2 - Mostra Desenvolvimento Marketing
$Self->{TicketAcl}->{'2 - Mostra Desenvolvimento Marketing'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_MKTDesenvolvimentoPPT' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_MKTMateriasDigitais' => [
        'Desenvolvimento de PPT'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-11-18 17:45:46 (diogo.viana)
# Changed: 2025-11-18 17:51:27 (diogo.viana)
# Comment: 2 - Mostra Digitais Marketing
$Self->{TicketAcl}->{'2 - Mostra Digitais Marketing'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_MKTMateriasDigitais' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_MKTMateriasComunicacao' => [
        'Materiais Digitais'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-11-28 16:56:45 (diogo.viana)
# Changed: 2026-10-14 14:45:38 (rodrigo.maia)
# Comment: 2 - Mostra Diária no Carregamento - Nota Fiscal
$Self->{TicketAcl}->{'2 - Mostra Diária no Carregamento - Nota Fiscal'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NotaFiscalCarregamento' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_CteClienteTipoNestle' => [
        'NESTLE',
        'NESTLE PURINA'
      ],
      'DynamicField_CteOcorrencia' => [
        '[RegExp]^.+$'
      ]
    },
    'Process' => {
      'ProcessEntityID' => [
        'Process-56ca5a2f78e80b672d746c80e1ef0e95'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 1
};

# Created: 2025-09-05 10:51:17 (mikael.oliveira)
# Changed: 2025-12-10 19:01:06 (diogo.viana)
$Self->{TicketAcl}->{'2 - Mostra Erro Integração NewKMM'} = {
  'Possible' => {},
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {},
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-09-04 10:43:49 (mikael.oliveira)
# Changed: 2025-12-10 19:28:34 (diogo.viana)
# Comment: 2 - Mostra Etapa Carga NewKMM
$Self->{TicketAcl}->{'2 - Mostra Etapa Carga NewKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NewKMMCargaEtapas' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_NewKMMTela' => [
        'Carga'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-11-18 18:22:00 (diogo.viana)
# Changed: 2025-11-18 18:23:18 (diogo.viana)
# Comment: 2 - Mostra Fotografia Marketing
$Self->{TicketAcl}->{'2 - Mostra Fotografia Marketing'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_MKTFotografia' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_MKTComunicacaoDivulgacao' => [
        'Fotografia'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-11-18 17:48:18 (diogo.viana)
# Changed: 2025-11-18 17:50:17 (diogo.viana)
# Comment: 2 - Mostra Graficos Marketing
$Self->{TicketAcl}->{'2 - Mostra Graficos Marketing'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_MKTMateriasGraficos' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_MKTMateriasComunicacao' => [
        'Materiais Gráficos'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-12-10 19:08:23 (diogo.viana)
# Changed: 2026-01-22 15:52:22 (diogo.viana)
# Comment: 2 - Mostra Numero Carga NewKMM
$Self->{TicketAcl}->{'2 - Mostra Numero Carga NewKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NewKMMNumCarga' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_NewKMMTela' => [
        'Carga',
        'Cancelamento de Carga',
        'Ocorrência',
        'Atendimento'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2026-01-22 15:35:32 (diogo.viana)
# Changed: 2026-01-22 15:51:26 (diogo.viana)
# Comment: 2 - Mostra Numero Carga OldKMM
$Self->{TicketAcl}->{'2 - Mostra Numero Carga OldKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NewKMMNumCarga' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_OldKMMTela' => [
        'Carga'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-12-15 10:42:23 (diogo.viana)
# Changed: 2025-12-15 10:49:10 (diogo.viana)
# Comment: 2 - Mostra Placa NewKMM
$Self->{TicketAcl}->{'2 - Mostra Placa NewKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NewKMMPlaca' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_NewKMMCadastro' => [
        'Veículo'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2026-01-22 16:24:25 (diogo.viana)
# Changed: 2026-01-22 16:27:39 (diogo.viana)
# Comment: 2 - Mostra Placa OldKMM
$Self->{TicketAcl}->{'2 - Mostra Placa OldKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NewKMMPlaca' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_OldKMMTela' => [
        'Placa'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-12-01 18:28:27 (diogo.viana)
# Changed: 2025-12-01 18:31:21 (diogo.viana)
# Comment: 2 - Mostra Troca de Nota - Nota Fiscal
$Self->{TicketAcl}->{'2 - Mostra Troca de Nota - Nota Fiscal'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NotaFiscalTroca' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_CteClienteTipoNestle' => [
        'NESTLE',
        'NESTLE PURINA'
      ]
    },
    'Process' => {
      'ProcessEntityID' => [
        'Process-a0a908b48965ce51bc22e44e3e93bb4e'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-11-28 18:10:11 (diogo.viana)
# Changed: 2026-10-14 14:49:23 (rodrigo.maia)
# Comment: 2 - Mostrar Diária no Posto Fiscal - Pedir CTE PDF e Rastreamento
$Self->{TicketAcl}->{'2 - Mostrar Diária no Posto Fiscal - Pedir CTE PDF e Rastreamento'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CTePDF' => [
        '2'
      ],
      'DynamicField_CteAnexoPosicaoRastreador' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_CteClienteTipoNestle' => [
        'NESTLE',
        'NESTLE PURINA'
      ]
    },
    'Process' => {
      'ProcessEntityID' => [
        'Process-97018c99b310c7426343f6eb090bf6cf'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-11-28 17:55:28 (diogo.viana)
# Changed: 2026-10-14 14:49:40 (rodrigo.maia)
# Comment: 2 Mostra Diária na Devolução - CTE assinado e Rastreamento
$Self->{TicketAcl}->{'2 Mostra Diária na Devolução - CTE assinado e Rastreamento'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteAnexoPosicaoRastreador' => [
        '2'
      ],
      'DynamicField_CteDACTECarimbadoAssinado' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_CteClienteTipoNestle' => [
        'NESTLE',
        'NESTLE PURINA'
      ]
    },
    'Process' => {
      'ProcessEntityID' => [
        'Process-f0cadeb17523c1002104bffc80ebe225'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-12-23 16:16:10 (gutemberg.souza)
# Changed: 2021-12-23 16:18:21 (gutemberg.souza)
$Self->{TicketAcl}->{'2- EsconderViagemSeara'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_ViagemSeara' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_CteNomePagador' => [
        '[Not]SEARA'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:15:40 (samuel.euzebio)
# Changed: 2026-10-14 15:45:48 (rodrigo.maia)
# Comment: Mostra Anexo Posicao Rastreador Processo : DIÁRIA AO DESCARREGAR
$Self->{TicketAcl}->{'2- Mostra Anexo Posicao Rastreador Processo : DIÁRIA AO DESCARREGAR'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteAnexoPosicaoRastreador' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_CteClienteTipoNestle' => [
        'NESTLE'
      ]
    },
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-b3ab90b93dfe94a87d5bfdeffc3cec0c',
        'ActivityDialog-e9eced752f80de08ce7a56dec3b12697',
        'ActivityDialog-a96ea4e798e67fe9c789f87b8968c048',
        'ActivityDialog-e9eced752f80de08ce7a56dec3b12697'
      ],
      'ProcessEntityID' => [
        'Process-29d7aad86f50e8197f56341c71c4bf90',
        'Process-97018c99b310c7426343f6eb090bf6cf',
        'Process-56ca5a2f78e80b672d746c80e1ef0e95',
        'Process-a0a908b48965ce51bc22e44e3e93bb4e'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:16:25 (samuel.euzebio)
# Changed: 2021-10-29 10:47:43 (rodrigo.maia)
# Comment: 2- Mostra Anexo Recibo de Descarga
$Self->{TicketAcl}->{'2- Mostra Anexo Recibo de Descarga'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteAnexoReciboDescarga' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-380e90623264f051b87cf8a72e538865'
      ],
      'ProcessEntityID' => [
        'Process-646f00304cc7a849fb29520a71c85733'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-11-18 15:49:44 (diogo.viana)
# Changed: 2025-11-18 15:49:44 (diogo.viana)
# Comment: 2- Mostra Anexo Recibo de Descarga
$Self->{TicketAcl}->{'2- Mostra Anexo Recibo de Descarga(copiar)1'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteAnexoReciboDescarga' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-380e90623264f051b87cf8a72e538865'
      ],
      'ProcessEntityID' => [
        'Process-646f00304cc7a849fb29520a71c85733'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:16:42 (samuel.euzebio)
# Changed: 2026-10-14 14:47:27 (rodrigo.maia)
# Comment: Mostra Campos Chamado
$Self->{TicketAcl}->{'2- Mostra Campos Chamado'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteCnpjPagador' => [
        '2'
      ],
      'DynamicField_CteDataEmissao' => [
        '2'
      ],
      'DynamicField_CteFilial' => [
        '2'
      ],
      'DynamicField_CteFilialNome' => [
        '2'
      ],
      'DynamicField_CteNomePagador' => [
        '2'
      ],
      'DynamicField_CteNumero' => [
        '2'
      ],
      'DynamicField_CtePlaca' => [
        '2'
      ],
      'DynamicField_CteSerie' => [
        '2'
      ],
      'DynamicField_ManifestoData' => [
        '2'
      ],
      'DynamicField_ManifestoNumero' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_CteDB' => [
        '[RegExp].'
      ],
      'DynamicField_Placa' => [
        '[RegExp].'
      ]
    },
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-b3ab90b93dfe94a87d5bfdeffc3cec0c',
        'ActivityDialog-189c08089f5763a841a9942228fafdf3',
        'ActivityDialog-dc48d1afd0dbd7e535dcd41b26d3a29e',
        'ActivityDialog-c358079ebd217f3b6bac5359d59ac82f',
        'ActivityDialog-a96ea4e798e67fe9c789f87b8968c048',
        'ActivityDialog-b63401ae0715ef538233f7be338af8b7',
        'ActivityDialog-e7281b17803a9beb7008dbab2c213026',
        'ActivityDialog-1706111e7d5f598897f915110342d1f0',
        'ActivityDialog-380e90623264f051b87cf8a72e538865',
        'Activity-1be67e6c0c9b8de86a6fac46eab0119d',
        'ActivityDialog-31530c3cd24925fb400dc24f9fc9248d'
      ],
      'ProcessEntityID' => [
        'Process-29d7aad86f50e8197f56341c71c4bf90',
        'Process-f9db7cf70938e64af70a2688bc152d75',
        'Process-646f00304cc7a849fb29520a71c85733',
        'Process-4b491ffe20345a28e32555c19f993a7d',
        'Process-97018c99b310c7426343f6eb090bf6cf',
        'Process-56ca5a2f78e80b672d746c80e1ef0e95',
        'Process-a0a908b48965ce51bc22e44e3e93bb4e',
        'Process-02f4ecb1397d6dc35826527c83b9f199',
        'Process-e8b53c963d58c49c4e762d95a99fb686',
        'Process-cc83c965d123ff5b29595d2329f4edea'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:17:14 (samuel.euzebio)
# Changed: 2021-01-12 15:21:09 (samuel.euzebio)
# Comment: Mostra CteSenhaBRF Processo : DESLOCAMENTO
$Self->{TicketAcl}->{'2- Mostra CteSenhaBRF Processo : DESLOCAMENTO'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteCETBRF' => [
        '2'
      ],
      'DynamicField_CteSenhaBRF' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_CteNomePagador' => [
        'BRF'
      ]
    },
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-189c08089f5763a841a9942228fafdf3'
      ],
      'ProcessEntityID' => [
        'Process-f9db7cf70938e64af70a2688bc152d75'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:17:51 (samuel.euzebio)
# Changed: 2026-10-14 14:46:55 (rodrigo.maia)
# Comment: Mostra NotaDébito Marfrig Processo : DIÁRIA AO DESCARREGAR
$Self->{TicketAcl}->{'2- Mostra NotaDébito Marfrig Processo : DIÁRIA AO DESCARREGAR'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteNotaDebitoMarfrig' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_CteNomePagador' => [
        'MARFRIG'
      ]
    },
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-645dce235354bf7b59c721b690b9bc4b',
        'ActivityDialog-380e90623264f051b87cf8a72e538865',
        'ActivityDialog-a96ea4e798e67fe9c789f87b8968c048',
        'ActivityDialog-189c08089f5763a841a9942228fafdf3'
      ],
      'ProcessEntityID' => [
        'Process-ffae7f17de2c0db2c5df95bbf3dd281f',
        'Process-646f00304cc7a849fb29520a71c85733',
        'Process-56ca5a2f78e80b672d746c80e1ef0e95',
        'Process-f9db7cf70938e64af70a2688bc152d75'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:19:05 (samuel.euzebio)
# Changed: 2026-10-14 14:46:45 (rodrigo.maia)
# Comment: Mostra Numero Registro BRF Processo : DIÁRIA AO DESCARREGAR
$Self->{TicketAcl}->{'2- Mostra Numero Registro BRF Processo : DIÁRIA AO DESCARREGAR'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteNumeroRegistroBRF' => [
        '1'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_CteNomePagador' => [
        'BRF'
      ]
    },
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-645dce235354bf7b59c721b690b9bc4b',
        'ActivityDialog-a96ea4e798e67fe9c789f87b8968c048',
        'ActivityDialog-189c08089f5763a841a9942228fafdf3',
        'ActivityDialog-b3ab90b93dfe94a87d5bfdeffc3cec0c'
      ],
      'ProcessEntityID' => [
        'Process-ffae7f17de2c0db2c5df95bbf3dd281f',
        'Process-56ca5a2f78e80b672d746c80e1ef0e95',
        'Process-f9db7cf70938e64af70a2688bc152d75',
        'Process-29d7aad86f50e8197f56341c71c4bf90'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:19:17 (samuel.euzebio)
# Changed: 2026-10-15 09:58:39 (rodrigo.maia)
# Comment: MostraOcorrencia Todos Processos  NESTLE
$Self->{TicketAcl}->{'2- Mostra Ocorrencia Todos Processos  NESTLE'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteOcorrencia' => [
        '3'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_CteClienteTipoNestle' => [
        'NESTLE',
        'NESTLE PURINA'
      ]
    },
    'Process' => {
      'ProcessEntityID' => [
        'Process-a0a908b48965ce51bc22e44e3e93bb4e',
        'Process-56ca5a2f78e80b672d746c80e1ef0e95',
        'Process-97018c99b310c7426343f6eb090bf6cf',
        'Process-29d7aad86f50e8197f56341c71c4bf90',
        'Process-f0cadeb17523c1002104bffc80ebe225'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:19:52 (samuel.euzebio)
# Changed: 2021-12-23 15:28:51 (gutemberg.souza)
# Comment: 2- Mostra Senha Marfrig Processo : Recibo de Descarga nao obrigatorio
$Self->{TicketAcl}->{'2- Mostra Senha Marfrig Processo : Recibo de Descarga nao obrigatorio'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteSenhaMarfrig' => [
        '1'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_CteNomePagador' => [
        'MARFRIG'
      ]
    },
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-380e90623264f051b87cf8a72e538865'
      ],
      'ProcessEntityID' => [
        'Process-646f00304cc7a849fb29520a71c85733'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:20:30 (samuel.euzebio)
# Changed: 2026-10-14 14:46:04 (rodrigo.maia)
# Comment: Mostra Senha Marfrig Processo : DIÁRIA AO DESCARREGAR
$Self->{TicketAcl}->{'2- Mostra Senha Marfrig Processos : DIÁRIA'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteSenhaMarfrig' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_CteNomePagador' => [
        'MARFRIG'
      ]
    },
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-645dce235354bf7b59c721b690b9bc4b',
        'ActivityDialog-a96ea4e798e67fe9c789f87b8968c048',
        'ActivityDialog-b3ab90b93dfe94a87d5bfdeffc3cec0c',
        'ActivityDialog-b63401ae0715ef538233f7be338af8b7'
      ],
      'ProcessEntityID' => [
        'Process-ffae7f17de2c0db2c5df95bbf3dd281f',
        'Process-56ca5a2f78e80b672d746c80e1ef0e95',
        'Process-29d7aad86f50e8197f56341c71c4bf90',
        'Process-a0a908b48965ce51bc22e44e3e93bb4e'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-12-23 15:04:26 (gutemberg.souza)
# Changed: 2021-12-23 16:35:41 (gutemberg.souza)
# Comment: Mostrar quando a viagem for Seara
$Self->{TicketAcl}->{'2- MostraViagemSeara'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_ViagemSeara' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_CteNomePagador' => [
        'SEARA'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2026-04-13 16:36:36 (diogo.viana)
# Changed: 2026-04-13 16:37:20 (diogo.viana)
$Self->{TicketAcl}->{'2Show FichaMatriculaPF'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CodCPF' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_FichaMatriculaPersonType' => [
        'Física'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2026-04-13 16:33:11 (diogo.viana)
# Changed: 2026-04-13 16:36:22 (diogo.viana)
$Self->{TicketAcl}->{'2Show FichaMatriculaPJ'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CodCGCCnpj' => [
        '2'
      ],
      'DynamicField_FichaMatriculaAnexoContratoSocial' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_FichaMatriculaPersonType' => [
        'Jurídica'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2026-03-27 16:40:46 (diogo.viana)
# Changed: 2026-03-27 16:43:07 (diogo.viana)
$Self->{TicketAcl}->{'2Show TIInfraNewEmployeeCostCenter'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_TIInfraNewEmployeeCostCenter' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_TIInfraNewEmployeeSystems' => [
        'NewKMM / MultiTMS'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2026-03-27 16:43:19 (diogo.viana)
# Changed: 2026-03-27 16:44:49 (diogo.viana)
$Self->{TicketAcl}->{'2Show TIInfraNewEmployeeEmailGroups'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_TIInfraNewEmployeeEmailGroups' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_TIInfraNewEmployeeSystems' => [
        'E-mail'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-12-14 14:39:13 (rodrigo.maia)
# Changed: 2024-11-25 19:03:58 (samuel.euzebio)
$Self->{TicketAcl}->{'3 - Contraturno Esconder Campos'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_Adiantamento' => [
        '0'
      ],
      'DynamicField_ContraturnoPercent' => [
        '0'
      ],
      'DynamicField_ContraturnoPercentAdto' => [
        '0'
      ],
      'DynamicField_ContraturnoVlrFixPercent' => [
        '0'
      ],
      'DynamicField_Cotacao' => [
        '0'
      ],
      'DynamicField_CteOrigemContraturno' => [
        '0'
      ],
      'DynamicField_CteSubcontratoContraturno' => [
        '0'
      ],
      'DynamicField_FilialCotacao' => [
        '0'
      ],
      'DynamicField_FretesNestleNegociado' => [
        '0'
      ],
      'DynamicField_Numero' => [
        '0'
      ],
      'DynamicField_NumeroCotacao' => [
        '0'
      ],
      'DynamicField_ValorTransportado' => [
        '0'
      ],
      'DynamicField_ValorTransportadorContraturno' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {},
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-12-14 14:35:12 (rodrigo.maia)
# Changed: 2021-12-21 11:20:52 (gutemberg.souza)
$Self->{TicketAcl}->{'3 - Contraturno Mostra Campos Nestle'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_FretesNestleNegociado' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_TipodeOperacao' => [
        'Nestle'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-12-15 11:13:46 (diogo.viana)
# Changed: 2026-01-22 16:07:28 (diogo.viana)
# Comment: 3 - Esconde CNPJ / CPF NewKMM
$Self->{TicketAcl}->{'3 - Esconde CNPJ / CPF NewKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NewKMMCnpjCpf' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_NewKMMCadastro' => [
        '[NotRegExp]^(?:Motorista|Pessoa)$'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-12-15 11:25:24 (diogo.viana)
# Changed: 2026-01-22 16:28:41 (diogo.viana)
# Comment: 3 - Esconde CNPJ / CPF Placa NewKMM
$Self->{TicketAcl}->{'3 - Esconde CNPJ / CPF Placa NewKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NewKMMCnpjCpf' => [
        '0'
      ],
      'DynamicField_NewKMMPlaca' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_NewKMMTela' => [
        '[Not]Cadastro'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:21:55 (samuel.euzebio)
# Changed: 2026-10-14 15:50:04 (rodrigo.maia)
# Comment: 3 - Esconde DACTE Carimbado Assinado BRF Diarias
$Self->{TicketAcl}->{'3 - Esconde DACTE Carimbado Assinado e Posicao Rastreador BRF Diarias'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteAnexoPosicaoRastreador' => [
        '0'
      ],
      'DynamicField_CteDACTECarimbadoAssinado' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_CteNomePagador' => [
        'BRF'
      ]
    },
    'Process' => {
      'ProcessEntityID' => [
        'Process-29d7aad86f50e8197f56341c71c4bf90',
        'Process-97018c99b310c7426343f6eb090bf6cf',
        'Process-56ca5a2f78e80b672d746c80e1ef0e95',
        'Process-a0a908b48965ce51bc22e44e3e93bb4e'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-11-19 08:33:06 (diogo.viana)
# Changed: 2025-11-19 08:40:13 (diogo.viana)
# Comment: 3 - Esconde Desenvolvimento Marketing
$Self->{TicketAcl}->{'3 - Esconde Desenvolvimento Marketing'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_MKTDesenvolvimentoPPT' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_MKTMateriasComunicacao' => [
        '[Not]Materiais Digitais'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-12-10 19:12:48 (diogo.viana)
# Changed: 2025-12-10 19:49:06 (diogo.viana)
# Comment: 3 - Esconde Etapas Erro Integracao Carga NewKMM
$Self->{TicketAcl}->{'3 - Esconde Etapas Erro Integracao Carga NewKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NewKMMCargaEtapas' => [
        '0'
      ],
      'DynamicField_NewKMMErroIntegracao' => [
        '0'
      ],
      'DynamicField_NewKMMEtapa1' => [
        '0'
      ],
      'DynamicField_NewKMMEtapa2' => [
        '0'
      ],
      'DynamicField_NewKMMEtapa3' => [
        '0'
      ],
      'DynamicField_NewKMMEtapa4' => [
        '0'
      ],
      'DynamicField_NewKMMEtapa5' => [
        '0'
      ],
      'DynamicField_NewKMMEtapa6' => [
        '0'
      ],
      'DynamicField_NewKMMEtapa7' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_NewKMMTela' => [
        '[Not]Carga'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-11-19 08:46:28 (diogo.viana)
# Changed: 2025-11-19 08:48:05 (diogo.viana)
# Comment: 3 - Esconde Fotografia Marketing
$Self->{TicketAcl}->{'3 - Esconde Fotografia Marketing'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_MKTFotografia' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_MKTMateriasComunicacao' => [
        '[Not]Comunicação ou Divulgação'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-12-10 19:41:41 (diogo.viana)
# Changed: 2026-01-22 15:39:52 (diogo.viana)
# Comment: 3 - Esconde Numero Carga NewKMM/OldKMM
$Self->{TicketAcl}->{'3 - Esconde Numero Carga NewKMM/OldKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NewKMMNumCarga' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_NewKMMTela' => [
        '[NotRegExp]^(?:Cancelamento de Carga|Carga|Ocorrência|Atendimento)$'
      ],
      'DynamicField_OldKMMTela' => [
        '[NotRegExp]^(?:Carga)$'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-12-15 11:16:27 (diogo.viana)
# Changed: 2025-12-15 11:24:44 (diogo.viana)
# Comment: 3 - Esconde Placa NewKMM
$Self->{TicketAcl}->{'3 - Esconde Placa NewKMM'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_NewKMMPlaca' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_TipoCadastro' => [
        '[Not]Veículo'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2020-11-26 09:20:26 (samuel.euzebio)
# Changed: 2025-04-24 11:40:29 (samuel.euzebio)
# Comment: Esconde Serviços Jurídicos
$Self->{TicketAcl}->{'3 - Esconde Serviços Jurídicos Vieceli e Cootravale e Cristofolini'} = {
  'Possible' => {},
  'PossibleAdd' => {},
  'PossibleNot' => {
    'Ticket' => {
      'Service' => [
        '[RegExp]^Jurídico'
      ]
    }
  },
  'Properties' => {
    'CustomerUser' => {
      'Group_rw' => [
        'Usuários Clientes Geral'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2020-11-11 09:30:38 (samuel.euzebio)
# Changed: 2021-06-15 11:17:39 (samuel.euzebio)
$Self->{TicketAcl}->{'3 - Esconde Serviços Não Juridicos'} = {
  'Possible' => {
    'Ticket' => {
      'Service' => [
        '[RegExp]Jurídico Cootravale'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'CustomerUser' => {
      'Group_rw' => [
        'Jurídico Cootravale Cliente'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 17:06:35 (samuel.euzebio)
# Changed: 2021-10-20 11:33:29 (rodrigo.maia)
# Comment: Esconde Serviços Processo
$Self->{TicketAcl}->{'3 - Esconde Serviços Processo'} = {
  'Possible' => {},
  'PossibleAdd' => {},
  'PossibleNot' => {
    'Ticket' => {
      'Service' => [
        '[RegExp]^Processo'
      ]
    }
  },
  'Properties' => {
    'CustomerUser' => {
      'Group_rw' => [
        'Usuários Clientes Geral'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-05-07 15:48:36 (samuel.euzebio)
# Changed: 2021-06-07 17:37:33 (samuel.euzebio)
# Comment: Esconde Filas Serviços Cootravale
$Self->{TicketAcl}->{'3- Esconde Filas Serviços Cootravale'} = {
  'Possible' => {},
  'PossibleAdd' => {},
  'PossibleNot' => {
    'Ticket' => {
      'Service' => [
        'Suprimentos::Dúvidas',
        'Suprimentos::Dúvidas::Lançamentos / Documentos',
        'Suprimentos'
      ]
    }
  },
  'Properties' => {
    'CustomerUser' => {
      'Group_rw' => [
        'Usuario Schmidt Cliente'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2026-01-28 17:02:46 (diogo.viana)
# Changed: 2026-10-14 14:32:27 (rodrigo.maia)
# Comment: 3- Esconde Ocorrencia Todos Processos  Não NESTLE
$Self->{TicketAcl}->{'3- Esconde Ocorrencia Todos Processos  Não NESTLE'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteOcorrencia' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_CteClienteTipoNestle' => [
        'CLIENTENAONESTLE'
      ]
    },
    'Process' => {
      'ProcessEntityID' => [
        'Process-a0a908b48965ce51bc22e44e3e93bb4e',
        'Process-56ca5a2f78e80b672d746c80e1ef0e95',
        'Process-97018c99b310c7426343f6eb090bf6cf',
        'Process-29d7aad86f50e8197f56341c71c4bf90',
        'Process-f0cadeb17523c1002104bffc80ebe225'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-06-07 17:24:55 (samuel.euzebio)
# Changed: 2025-04-24 11:41:45 (samuel.euzebio)
# Comment: 3- Esconde Servicos Juridico Cristofolini para Escritorio Cristofolini
$Self->{TicketAcl}->{'3- Esconde Servicos Juridico Cristofolini para Escritorio Cristofolini'} = {
  'Possible' => {},
  'PossibleAdd' => {},
  'PossibleNot' => {
    'Ticket' => {
      'Service' => [
        '[RegExp]^Jurídico Cristofolini'
      ]
    }
  },
  'Properties' => {
    'CustomerUser' => {
      'Group_rw' => [
        'Usuario Cristofolini Cliente'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-07-22 10:20:44 (samuel.euzebio)
# Changed: 2025-07-22 10:21:22 (samuel.euzebio)
# Comment: 3- Esconde Servicos Melhorias TI para não Gestores
$Self->{TicketAcl}->{'3- Esconde Servicos Melhorias TI para não Gestores'} = {
  'Possible' => {},
  'PossibleAdd' => {},
  'PossibleNot' => {
    'Ticket' => {
      'TI::Melhorias' => []
    }
  },
  'Properties' => {
    'CustomerUser' => {
      'Usuários Clientes Geral' => []
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-07-26 11:16:01 (samuel.euzebio)
# Changed: 2021-08-30 18:12:00 (samuel.euzebio)
# Comment: 3- Esconde Servicos RH para não Gestores
$Self->{TicketAcl}->{'3- Esconde Servicos RH para não Gestores'} = {
  'Possible' => {},
  'PossibleAdd' => {},
  'PossibleNot' => {
    'Ticket' => {
      'Service' => [
        'RH::Rescisão::Rescisão de Contrato - Desligamento por Parte da Cooperativa',
        'RH::Rescisão::Rescisão de Contrato - Desligamento por Parte do Colaborador',
        'RH::Rescisão::Rescisão de Contrato - Simulação de Rescisão',
        'RH::Rescisão',
        'RH::Férias',
        'RH::Medidas Disciplinares',
        'RH::Remuneração e Movimentação - Cargo/Setor/Unidade/Centro de Custos',
        'RH::Recrutamento e Seleção',
        'RH::Remuneração',
        'RH::Treinamento'
      ]
    }
  },
  'Properties' => {
    'CustomerUser' => {
      'Group_rw' => [
        'Usuários Clientes Geral'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-06-07 17:40:24 (samuel.euzebio)
# Changed: 2021-06-07 17:44:59 (samuel.euzebio)
# Comment: 3- Esconde Todos Servicos  para Escritorio Schmidt
$Self->{TicketAcl}->{'3- Esconde Todos Servicos  para Escritorio Schmidt'} = {
  'Possible' => {},
  'PossibleAdd' => {},
  'PossibleNot' => {
    'Ticket' => {
      'Service' => [
        '[RegExp]^'
      ]
    }
  },
  'Properties' => {
    'CustomerUser' => {
      'Group_rw' => [
        'Usuario Schmidt Cliente'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:22:17 (samuel.euzebio)
# Changed: 2021-10-13 09:58:07 (samuel.euzebio)
# Comment: Somente para os transportadores abrirem chamado via processo.
$Self->{TicketAcl}->{'4 - Esconde Serviços  para Transportadores Cooperados'} = {
  'Possible' => {},
  'PossibleAdd' => {},
  'PossibleNot' => {
    'Ticket' => {
      'Service' => [
        '[RegExp]^'
      ]
    }
  },
  'Properties' => {
    'CustomerUser' => {
      'Group_rw' => [
        'Transportadores'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-02-11 09:13:39 (rodrigo.maia)
# Changed: 2025-07-17 11:03:53 (samuel.euzebio)
$Self->{TicketAcl}->{'4- Esconde Serviços Cootravale para  Edukar dos usuarios Geral'} = {
  'Possible' => {},
  'PossibleAdd' => {},
  'PossibleNot' => {
    'Ticket' => {
      'Service' => [
        'CRC',
        'Comercial',
        'Emissao Contraturno MultiTMS',
        'Ficha Matrícula',
        'GR',
        'Jurídico Cootravale',
        'Jurídico Cristofolini',
        'Logística Operações',
        'Marketing',
        'Monitoramento - Torre de Controle',
        'Qualidade',
        'Supervisão de Frota',
        'Viagens'
      ]
    }
  },
  'Properties' => {
    'CustomerUser' => {
      'Group_rw' => [
        'EDUKAR Cliente'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2020-12-11 10:42:06 (samuel.euzebio)
# Changed: 2021-07-30 11:19:41 (samuel.euzebio)
$Self->{TicketAcl}->{'5 - Jurídico Vieceli e Schmidt Remover Opção Nota'} = {
  'Possible' => {},
  'PossibleAdd' => {},
  'PossibleNot' => {
    'Action' => [
      'AgentTicketNote'
    ]
  },
  'Properties' => {
    'Ticket' => {
      'Queue' => [
        'Jurídico Vieceli',
        'Jurídico Schmidt'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2022-04-18 16:09:00 (gutemberg.souza)
# Changed: 2022-04-18 16:13:24 (gutemberg.souza)
# Comment: 5 - Mostra Serviços Comercial
$Self->{TicketAcl}->{'5 - Mostra Serviços Comercial'} = {
  'Possible' => {},
  'PossibleAdd' => {
    'Ticket' => {
      'Service' => [
        'Complemento de Frete'
      ]
    }
  },
  'PossibleNot' => {},
  'Properties' => {
    'CustomerUser' => {
      'group_rw' => [
        'CRC'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-05-26 16:42:25 (rodrigo.maia)
# Changed: 2021-06-04 08:46:19 (rodrigo.maia)
# Comment: 5 - Mostra Serviços Suprimentos
$Self->{TicketAcl}->{'5 - Mostra Serviços Suprimentos'} = {
  'Possible' => {},
  'PossibleAdd' => {
    'Ticket' => {
      'Service' => [
        'Suprimentos',
        'Suprimentos::Manutenção::Outros Serviços',
        'Suprimentos::Compras',
        'Suprimentos::Compras::Brindes',
        'Suprimentos::Compras::Material de Expediente',
        'Suprimentos::Compras::Periféricos',
        'Suprimentos::Compras::Serviços Externos',
        'Suprimentos::Manutenção::Elétrica',
        'Suprimentos::Manutenção::Outros Serviços',
        'Suprimentos::Manutenção::Predial',
        'Suprimentos::Outros',
        'Suprimentos::Outros::Dúvidas',
        'Suprimentos::Outros::Sugestões',
        'Suprimentos::Manutenção'
      ]
    }
  },
  'PossibleNot' => {},
  'Properties' => {
    'CustomerUser' => {
      'group_rw' => [
        'Usuários Clientes Geral'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-03-04 16:22:38 (samuel.euzebio)
# Changed: 2025-04-24 11:44:28 (samuel.euzebio)
# Comment: Mostra serviço Jurídico Schmidt
$Self->{TicketAcl}->{'5 - Mostra serviço Jurídico Schmidt'} = {
  'Possible' => {},
  'PossibleAdd' => {
    'Ticket' => {
      'Service' => [
        'Jurídico Cristofolini',
        'Jurídico Cristofolini::Cível Cliente',
        'Jurídico Cristofolini::Cível Fornecedor',
        'Jurídico Cristofolini::Cível Outros',
        'Jurídico Cristofolini::Cível Transportador',
        'Jurídico Cristofolini::Outros Comercial',
        'Jurídico Cristofolini::Outros Financeiro',
        'Jurídico Cristofolini::Outros Operacional'
      ]
    }
  },
  'PossibleNot' => {},
  'Properties' => {
    'CustomerUser' => {
      'Group_rw' => [
        'Jurídico Cristofolini Cliente'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-03-19 17:31:32 (rodrigo.maia)
# Changed: 2021-03-19 17:37:55 (rodrigo.maia)
$Self->{TicketAcl}->{'5 - Mostra serviço Jurídico Schmidt Contábil'} = {
  'Possible' => {},
  'PossibleAdd' => {
    'Ticket' => {
      'Service' => [
        'Jurídico Schmidt::Cível Cliente',
        'Jurídico Schmidt'
      ]
    }
  },
  'PossibleNot' => {},
  'Properties' => {
    'CustomerUser' => {
      'Group_rw' => [
        'Jurídico Schmidt Contábil'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2025-07-22 10:14:16 (samuel.euzebio)
# Changed: 2025-08-25 10:10:17 (samuel.euzebio)
# Comment: 5 - Mostra serviço Melhorias TI para Gestores
$Self->{TicketAcl}->{'5 - Mostra serviço Melhorias TI para Gestores'} = {
  'Possible' => {},
  'PossibleAdd' => {
    'Ticket' => {
      'TI::Melhorias' => [
        'TI::Melhorias'
      ]
    }
  },
  'PossibleNot' => {},
  'Properties' => {
    'CustomerUser' => {
      'Group_rw' => [
        'Gestores Melhorias TI',
        'TI - Melhorias'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-07-26 11:55:24 (samuel.euzebio)
# Changed: 2021-08-30 18:11:43 (samuel.euzebio)
# Comment: 5 - Mostra serviço RH para Gestores
$Self->{TicketAcl}->{'5 - Mostra serviço RH para Gestores'} = {
  'Possible' => {},
  'PossibleAdd' => {
    'Ticket' => {
      'Service' => [
        'RH::Rescisão',
        'RH::Rescisão::Rescisão de Contrato - Desligamento por Parte da Cooperativa',
        'RH::Rescisão::Rescisão de Contrato - Desligamento por Parte do Colaborador',
        'RH::Rescisão::Rescisão de Contrato - Simulação de Rescisão',
        'RH::Férias',
        'RH::Férias::Férias - Agendamento de férias',
        'RH::Férias::Férias - Cancelamento de Férias',
        'RH::Férias::Férias - Relátorio de Férias',
        'RH::Medidas Disciplinares',
        'RH::Medidas Disciplinares::Medidas Disciplinares - Advertência',
        'RH::Medidas Disciplinares::Medidas Disciplinares - Suspensão',
        'RH::Recrutamento e Seleção',
        'RH::Recrutamento e Seleção::Recrutamento e Seleção - Contratação/Substituíção Gestão',
        'RH::Recrutamento e Seleção::Recrutamento e Seleção - Contratação/Substituíção',
        'RH::Recrutamento e Seleção::Recrutamento e Seleção - Recrutamento Interno',
        'RH::Remuneração e Movimentação - Cargo/Setor/Unidade/Centro de Custos',
        'RH::Remuneração',
        'RH::Treinamento'
      ]
    }
  },
  'PossibleNot' => {},
  'Properties' => {
    'CustomerUser' => {
      'Group_rw' => [
        'Gestores Cliente RH'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-02-11 09:36:06 (rodrigo.maia)
# Changed: 2025-07-17 11:01:38 (samuel.euzebio)
# Comment: Mostra serviços cootravale para escritório Contábil. Edukar
$Self->{TicketAcl}->{'5- Mostra Catalogo de Serviços Cootravale x Edukar'} = {
  'Possible' => {},
  'PossibleAdd' => {
    'Ticket' => {
      'Service' => [
        'Contas a Pagar::Dúvida de Usuário - CAP::Lançamentos / Documentos',
        'Contas a Pagar::Ajustes::Correção de Lançamentos',
        'Societário::Ajustes::Correção de Lançamentos',
        'RH::Dúvidas::Lançamentos / Documentos',
        'RH::Ajustes::Correção de Lançamentos',
        'RH::Folha::Arquivo de Integração',
        'Suprimentos::Dúvidas::Lançamentos / Documentos',
        'Controladoria::Rodopar::Criação de Relatório',
        'Controladoria::Dúvidas::Lançamentos Contábeis',
        'TI',
        'Contas a Pagar',
        'Societário',
        'RH',
        'Suprimentos',
        'Contas a Pagar::Dúvida de Usuário - CAP',
        'Contas a Pagar::Ajustes',
        'Societário::Ajustes',
        'TI::Sistemas e Portais',
        'RH::Dúvidas',
        'RH::Ajustes',
        'Suprimentos::Dúvidas',
        'Controladoria',
        'Controladoria::Rodopar',
        'Controladoria::Dúvidas',
        'Societário::Dúvidas e Orientações',
        'Societário::Dúvidas e Orientações::Lançamentos / Documentos',
        'TI::Sistemas e Portais::Rodopar',
        'TI::Sistemas e Portais::Rodopar::Falha Sistema Rodopar',
        'RH::Folha',
        'Suprimentos::Ajustes::Correção de Lançamentos',
        'Suprimentos::Ajustes',
        'Suporte Operações::Dúvidas::Lançamentos / Documentos',
        'Suporte Operações',
        'Suporte Operações::Dúvidas',
        'Controladoria::Rodopar::Solicitação de Melhoria',
        'Controladoria::Rodopar::Ajuste de Relatório',
        'Controladoria::Rodopar::Cadastro de Usuário',
        'Controladoria::Dúvidas::Parâmetros Financeiros',
        'Controladoria::Ajustes::Correção de Lançamentos',
        'Controladoria::Ajustes'
      ]
    }
  },
  'PossibleNot' => {},
  'Properties' => {
    'CustomerUser' => {
      'Group_rw' => [
        'EDUKAR'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-04-14 17:13:00 (samuel.euzebio)
# Changed: 2021-04-14 17:15:19 (samuel.euzebio)
# Comment: Mostra Somente Serviços Jurídicos Cootravale
$Self->{TicketAcl}->{'5- Mostra Somente Serviços Jurídicos Cootravale'} = {
  'Possible' => {},
  'PossibleAdd' => {
    'Ticket' => {
      'Service' => [
        'Jurídico Cootravale',
        'Jurídico Cootravale::Cível Comercial',
        'Jurídico Cootravale::Cível Financeiro',
        'Jurídico Cootravale::Cível Operacional',
        'Jurídico Cootravale::Outros Comercial',
        'Jurídico Cootravale::Outros Financeiro',
        'Jurídico Cootravale::Outros Operacional',
        'Jurídico Cootravale::Trabalhista Cootravale',
        'Jurídico Cootravale::Trabalhista LKW'
      ]
    }
  },
  'PossibleNot' => {},
  'Properties' => {
    'CustomerUser' => {
      'Group_rw' => [
        'Jurídico Cootravale Cliente'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-01-11 16:22:55 (samuel.euzebio)
# Changed: 2021-01-11 16:22:55 (samuel.euzebio)
$Self->{TicketAcl}->{'6 - Libera actions para admin'} = {
  'Possible' => {
    'Action' => [
      '[RegExp]^'
    ]
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'User' => {
      'Group_rw' => [
        'admin'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-04-01 17:39:25 (samuel.euzebio)
# Changed: 2025-04-24 11:48:38 (samuel.euzebio)
# Comment: 6 - Mostra serviço Jurídico Cristofolini Trab Comprovantes
$Self->{TicketAcl}->{'6 - Mostra serviço Jurídico Cristofolini Trab Comprovantes'} = {
  'Possible' => {},
  'PossibleAdd' => {
    'Ticket' => {
      'Service' => [
        'Jurídico Cristofolini::Trabalhista Comprovantes',
        'Jurídico Cristofolini'
      ]
    }
  },
  'PossibleNot' => {},
  'Properties' => {
    'CustomerUser' => {
      'Group_rw' => [
        'Jurídico Cristofolini Trabalhista Comprovante'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2020-12-21 18:07:16 (samuel.euzebio)
# Changed: 2025-04-24 11:48:06 (samuel.euzebio)
# Comment: Mostra serviço Jurídico Vieceli RH Cristofolini
$Self->{TicketAcl}->{'6 - Mostra serviço Jurídico RH Cristofolini'} = {
  'Possible' => {},
  'PossibleAdd' => {
    'Ticket' => {
      'Service' => [
        'Jurídico Cristofolini',
        'Jurídico Cristofolini::Trabalhista Cootravale',
        'Jurídico Cristofolini::Trabalhista LKW',
        'Jurídico Cristofolini::Trabalhista Comprovantes'
      ]
    }
  },
  'PossibleNot' => {},
  'Properties' => {
    'CustomerUser' => {
      'Group_rw' => [
        'RH Cristofolini'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-03-24 14:52:28 (samuel.euzebio)
# Changed: 2022-08-04 16:24:14 (samuel.euzebio)
# Comment: Mostra serviços Fiscal Edukar-usuarios Geral
$Self->{TicketAcl}->{'6 - Mostra serviços Fiscal Edukar-usuarios Geral'} = {
  'Possible' => {},
  'PossibleAdd' => {
    'Ticket' => {
      'Service' => [
        'Fiscal::Emissão NFS::Serviço',
        'Fiscal',
        'Fiscal::Emissão NFS',
        'Fiscal::Dúvidas e Orientações',
        'Fiscal::Dúvidas e Orientações::CT-e',
        'Fiscal::Dúvidas e Orientações::NFS',
        'Fiscal::Dúvidas e Orientações::Outros',
        'Fiscal::Emissão NFS::Produto',
        'Fiscal::Emissão NFS::Serviço',
        'Fiscal::Exceções Fiscais',
        'Fiscal::Parâmetros Fiscais',
        'Fiscal::Parâmetros Fiscais::Cliente Novo',
        'Fiscal::Parâmetros Fiscais::Exceção Fiscal',
        'Fiscal::Parâmetros Fiscais::Outros',
        'Fiscal::Solicitações',
        'Fiscal::Solicitações::Documentos',
        'Fiscal::Solicitações::Outros'
      ]
    }
  },
  'PossibleNot' => {},
  'Properties' => {
    'CustomerUser' => {
      'Group_rw' => [
        'Fiscal'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-11-26 16:20:40 (rodrigo.maia)
# Changed: 2021-12-01 11:34:59 (rodrigo.maia)
$Self->{TicketAcl}->{'7 - Esconde Campo Aprovação Formulário'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_ControleAprovacaoFrota' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'Process' => {
      'ActivityDialogEntityID' => [
        'ActivityDialog-b4a53bd46bdb501919b65fb94c43fed0'
      ],
      'ProcessEntityID' => [
        'Process-93d1d50abc0c949d7fe75ecbe27b9456'
      ]
    },
    'Ticket' => {
      'State' => [
        'open'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-11-30 10:28:33 (rodrigo.maia)
# Changed: 2021-11-30 11:05:37 (rodrigo.maia)
$Self->{TicketAcl}->{'8-  Esconde Formulário Pesquisa Motorista se Chamado Encerrado'} = {
  'Possible' => {},
  'PossibleAdd' => {},
  'PossibleNot' => {
    'ActivityDialog' => [
      'ActivityDialog-1e7f771b08285cea0537124d9b597e66'
    ]
  },
  'Properties' => {
    'Process' => {
      'ProcessEntityID' => [
        'Process-bbfccb85289bca9f6a15833bf61e7451'
      ]
    },
    'Ticket' => {
      'State' => [
        'closed successful',
        'closed unsuccessful',
        'closed with workaround'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2018-06-22 13:46:13 (adminotrs)
# Changed: 2018-06-22 13:47:18 (adminotrs)
$Self->{TicketAcl}->{'9998 - Filtra campos tipo SACAR'} = {
  'Possible' => {
    'Ticket' => {
      'Queue' => [
        'Qualidade'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'Ticket' => {
      'Type' => [
        'SACAR'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2018-05-23 11:21:46 (adminotrs)
# Changed: 2018-05-23 11:24:38 (adminotrs)
$Self->{TicketAcl}->{'9999 - Desativa Ligero Smart Classification'} = {
  'Possible' => {},
  'PossibleAdd' => {},
  'PossibleNot' => {
    'Action' => [
      'AgentTicketLigeroSmartClassification'
    ]
  },
  'Properties' => {
    'Ticket' => {
      'Service' => [
        '[RegExp]^'
      ],
      'Type' => [
        '[Not]Unclassified'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2024-11-26 11:59:23 (samuel.euzebio)
# Changed: 2024-11-26 12:09:33 (samuel.euzebio)
# Comment: Esconde os campos quando coop 1 e 2
$Self->{TicketAcl}->{'EscondeCamposCoop1Contraturno'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_Adiantamento' => [
        '0'
      ],
      'DynamicField_ContraturnoPercent' => [
        '0'
      ],
      'DynamicField_ContraturnoPercentAdto' => [
        '0'
      ],
      'DynamicField_ContraturnoVlrFixPercent' => [
        '0'
      ],
      'DynamicField_ValorTransportadorContraturno' => [
        '0'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_Cooperado' => [
        '1 ou 2'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-11-24 13:33:21 (rodrigo.maia)
# Changed: 2021-11-24 13:33:21 (rodrigo.maia)
$Self->{TicketAcl}->{'Mostra CteFilial'} = {
  'Possible' => {},
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {},
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2022-02-21 14:29:54 (gutemberg.souza)
# Changed: 2022-02-25 17:02:01 (gutemberg.souza)
# Comment: Mostrar Campos Pallet
$Self->{TicketAcl}->{'MostraCamposPallet'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteNomePagador' => [
        '2'
      ],
      'DynamicField_CteNumero' => [
        '2'
      ],
      'DynamicField_CteSerie' => [
        '2'
      ],
      'DynamicField_FilialCReceberDB' => [
        '2'
      ],
      'DynamicField_FilialEmissao' => [
        '2'
      ],
      'DynamicField_NomedoTransportadorPallet' => [
        '2'
      ],
      'DynamicField_NumerodoClientePallet' => [
        '2'
      ],
      'DynamicField_PesquisaNumeroDocumento' => [
        '2'
      ],
      'DynamicField_UnidadeNegocio' => [
        '2'
      ],
      'DynamicField_ValoraserDescontadodoTransportadorPallet' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_Demanda' => [
        'Pallet'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-12-21 11:21:32 (gutemberg.souza)
# Changed: 2021-12-21 11:45:05 (gutemberg.souza)
# Comment: Mostrar quando tipo de operação for subcontratado
$Self->{TicketAcl}->{'MostraCteSubcontratoContraturno'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteSubcontratoContraturno' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_TipodeOperacao' => [
        'Subcontratação'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-12-21 11:16:47 (gutemberg.souza)
# Changed: 2021-12-21 11:19:56 (gutemberg.souza)
# Comment: Mostrar quando tipo de operação for complementar
$Self->{TicketAcl}->{'MostraCtedeOrigemContraturno'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteOrigemContraturno' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_TipodeOperacao' => [
        'Complementar'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2024-11-25 18:00:07 (samuel.euzebio)
# Changed: 2024-11-25 19:03:36 (samuel.euzebio)
# Comment: Mostar quando Escolhido Percentual
$Self->{TicketAcl}->{'MostraPercentualContraturnoSelecao'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_ContraturnoPercent' => [
        '2'
      ],
      'DynamicField_ContraturnoPercentAdto' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_ContraturnoVlrFixPercent' => [
        'Percentual'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-12-17 14:35:45 (gutemberg.souza)
# Changed: 2024-11-25 17:46:22 (samuel.euzebio)
# Comment: Mostar quando Tipo Operação for 3 ou ANC
$Self->{TicketAcl}->{'MostraValorTransportadoContraturno'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_ContraturnoVlrFixPercent' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_Cooperado' => [
        '3 ou ANC'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2024-11-25 17:49:37 (samuel.euzebio)
# Changed: 2024-11-26 11:50:16 (samuel.euzebio)
# Comment: Mostar quando Escolhido Valor
$Self->{TicketAcl}->{'MostraValorTransportadoContraturnoSeleção'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_Adiantamento' => [
        '2'
      ],
      'DynamicField_ValorTransportadorContraturno' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_ContraturnoVlrFixPercent' => [
        'Valor Fixo'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-12-17 11:05:01 (gutemberg.souza)
# Changed: 2021-12-21 14:06:38 (gutemberg.souza)
# Comment: Mostrar quando frete for Negociado Contraturno
$Self->{TicketAcl}->{'MostrarFreteNegociadoContraturno'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_Cotacao' => [
        '2'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'DynamicField' => {
      'DynamicField_Frete' => [
        'Negociado'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2021-11-24 14:33:21 (rodrigo.maia)
# Changed: 2021-11-24 15:01:25 (rodrigo.maia)
$Self->{TicketAcl}->{'Solicitação de Emissão'} = {
  'Possible' => {
    'ShowHide' => {
      'DynamicField_CteFilial' => [
        '1'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'Service' => {
      'Name' => [
        'Suporte Operações::Solicitação de Emissão'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

# Created: 2020-11-13 17:41:28 (vanessa.serviceup)
# Changed: 2020-11-13 18:05:08 (vanessa.serviceup)
$Self->{TicketAcl}->{'zzz SLA Padrão'} = {
  'Possible' => {
    'Ticket' => {
      'SLA' => [
        'SLA Padrão'
      ]
    }
  },
  'PossibleAdd' => {},
  'PossibleNot' => {},
  'Properties' => {
    'Frontend' => {
      'Action' => [
        'CustomerTicketLessage'
      ]
    }
  },
  'PropertiesDatabase' => {},
  'StopAfterMatch' => 0
};

    return;
}
1;
