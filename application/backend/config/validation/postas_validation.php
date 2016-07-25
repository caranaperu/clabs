<?php

    $config['v_postas'] = [
        'getPostas' => [
            [
                'field' => 'postas_id',
                'label' => 'lang:postas_id',
                'rules' => 'required|integer|xss_clean'
            ]
        ],
        'updPostas' => [
            [
                'field' => 'postas_id',
                'label' => 'lang:postas_id',
                'rules' => 'required|integer|xss_clean'
            ],
            [
                'field' => 'competencias_pruebas_id',
                'label' => 'lang:competencias_pruebas_id',
                'rules' => 'required|integer|xss_clean'
            ],
            [
                'field' => 'postas_descripcion',
                'label' => 'lang:postas_descripcion',
                'rules' => 'xss_clean|max_length[50]'
            ],

            [
                'field' => 'versionId',
                'label' => 'lang:versionId',
                'rules' => 'required|integer|xss_clean'
            ]
        ],
        'delPostas' => [
            [
                'field' => 'postas_id',
                'label' => 'lang:postas_id',
                'rules' => 'required|integer|xss_clean'
            ],
            [
                'field' => 'versionId',
                'label' => 'lang:versionId',
                'rules' => 'required|integer|xss_clean'
            ]
        ],
        'addPostas' => [
            [
                'field' => 'competencias_pruebas_id',
                'label' => 'lang:competencias_pruebas_id',
                'rules' => 'required|integer|xss_clean'
            ],
            [
                'field' => 'postas_descripcion',
                'label' => 'lang:postas_descripcion',
                'rules' => 'xss_clean|max_length[50]'
            ]
        ]
    ];
?>