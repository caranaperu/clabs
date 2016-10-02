<?php

    $config['v_reglas'] = [
        'getReglas' => [
            [
                'field' => 'regla_id',
                'label' => 'lang:regla_id',
                'rules' => 'required|integer|xss_clean'
            ]
        ],
        'updReglas' => [
            [
                'field' => 'regla_id',
                'label' => 'lang:regla_id',
                'rules' => 'required|integer|xss_clean'
            ],
            [
                'field' => 'regla_empresa_origen_id',
                'label' => 'lang:regla_empresa_origen_id',
                'rules' => 'required|integer|xss_clean'
            ],
            [
                'field' => 'regla_empresa_destino_id',
                'label' => 'lang:regla_empresa_destino_id',
                'rules' => 'required|integer|xss_clean'
            ],
            [
                'field' => 'regla_by_costo',
                'label' => 'lang:regla_by_costo',
                'rules' => 'required|is_bool|xss_clean'
            ],
            [
                'field' => 'regla_porcentaje',
                'label' => 'lang:regla_porcentaje',
                'rules' => 'required|decimal|les_than[100.00] | xss_clean'
            ],
            [
                'field' => 'versionId',
                'label' => 'lang:versionId',
                'rules' => 'required|integer|xss_clean'
            ]
        ],
        'delReglas' => [
            [
                'field' => 'regla_id',
                'label' => 'lang:regla_id',
                'rules' => 'required|integer|xss_clean'
            ],
            [
                'field' => 'versionId',
                'label' => 'lang:versionId',
                'rules' => 'required|integer|xss_clean'
            ]
        ],
        'addReglas' => [
            [
                'field' => 'regla_empresa_origen_id',
                'label' => 'lang:regla_empresa_origen_id',
                'rules' => 'required|integer|xss_clean'
            ],
            [
                'field' => 'regla_empresa_destino_id',
                'label' => 'lang:regla_empresa_destino_id',
                'rules' => 'required|integer|xss_clean'
            ],
            [
                'field' => 'regla_by_costo',
                'label' => 'lang:regla_by_costo',
                'rules' => 'required|is_bool|xss_clean'
            ],
            [
                'field' => 'regla_porcentaje',
                'label' => 'lang:regla_porcentaje',
                'rules' => 'required|decimal|les_than[100.00] | xss_clean'
            ]
        ]
    ];
?>