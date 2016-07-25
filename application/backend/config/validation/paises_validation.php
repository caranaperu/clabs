<?php

    $config['v_paises'] = [
        'getPaises' => [
            [
                'field' => 'paises_codigo',
                'label' => 'lang:paises_codigo',
                'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
            ]
        ],
        'updPaises' => [
            [
                'field' => 'paises_codigo',
                'label' => 'lang:paises_codigo',
                'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
            ],
            [
                'field' => 'paises_descripcion',
                'label' => 'lang:paises_descripcion',
                'rules' => 'required|xss_clean|max_length[120]'
            ],
            [
                'field' => 'paises_entidad',
                'label' => 'lang:paises_entidad',
                'rules' => 'required|is_bool|xss_clean'
            ],
            [
                'field' => 'regiones_codigo',
                'label' => 'lang:regiones_codigo',
                'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
            ],
            [
                'field' => 'paises_use_apm',
                'label' => 'lang:paises_use_apm',
                'rules' => 'required|is_bool|xss_clean'
            ],
            [
                'field' => 'paises_use_docid',
                'label' => 'lang:paises_use_docid',
                'rules' => 'required|is_bool|xss_clean'
            ],
            [
                'field' => 'versionId',
                'label' => 'lang:versionId',
                'rules' => 'required|integer|xss_clean'
            ]
        ],
        'delPaises' => [
            [
                'field' => 'paises_codigo',
                'label' => 'lang:paises_codigo',
                'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
            ],
            [
                'field' => 'versionId',
                'label' => 'lang:versionId',
                'rules' => 'required|integer|xss_clean'
            ]
        ],
        'addPaises' => [
            [
                'field' => 'paises_codigo',
                'label' => 'lang:paises_codigo',
                'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
            ],
            [
                'field' => 'paises_descripcion',
                'label' => 'lang:paises_descripcion',
                'rules' => 'required|xss_clean|max_length[120]'
            ],
            [
                'field' => 'paises_entidad',
                'label' => 'lang:paises_entidad',
                'rules' => 'required|is_bool|xss_clean'
            ],
            [
                'field' => 'paises_use_apm',
                'label' => 'lang:paises_use_apm',
                'rules' => 'required|is_bool|xss_clean'
            ],
            [
                'field' => 'paises_use_docid',
                'label' => 'lang:paises_use_docid',
                'rules' => 'required|is_bool|xss_clean'
            ],
            [
                'field' => 'regiones_codigo',
                'label' => 'lang:regiones_codigo',
                'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
            ]
        ]
    ];
?>