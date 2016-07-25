<?php

    $config['v_postas_detalle'] = [
        'getPostasDetalle' => [
            [
                'field' => 'postas_detalle_id',
                'label' => 'lang:postas_detalle_id',
                'rules' => 'required|integer|xss_clean'
            ]
        ],
        'updPostasDetalle' => [
            [
                'field' => 'postas_detalle_id',
                'label' => 'lang:postas_detalle_id',
                'rules' => 'required|integer|xss_clean'
            ],
            [
                'field' => 'postas_id',
                'label' => 'lang:postas_id',
                'rules' => 'required|integer|xss_clean'
            ],
            [
                'field' => 'atletas_codigo',
                'label' => 'lang:atletas_codigo',
                'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
            ],
            [
                'field' => 'versionId',
                'label' => 'lang:versionId',
                'rules' => 'required|integer|xss_clean'
            ]
        ],
        'delPostasDetalle' => [
            [
                'field' => 'postas_detalle_id',
                'label' => 'lang:postas_detalle_id',
                'rules' => 'required|integer|xss_clean'
            ],
            [
                'field' => 'versionId',
                'label' => 'lang:versionId',
                'rules' => 'required|integer|xss_clean'
            ]
        ],
        'addPostasDetalle' => [
            [
                'field' => 'postas_id',
                'label' => 'lang:postas_id',
                'rules' => 'required|integer|xss_clean'
            ],
            [
                'field' => 'atletas_codigo',
                'label' => 'lang:atletas_codigo',
                'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
            ]
        ]
    ];
?>