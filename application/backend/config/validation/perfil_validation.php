<?php

    $config['v_perfil'] = [
        // Para la lectura de un contribuyente basado eb su id
        'getPerfil' => [
            [
                'field' => 'perfil_id',
                'label' => 'lang:perfil_id',
                'rules' => 'required|integer|xss_clean'
            ]
        ],
        'updPerfil' => [
            [
                'field' => 'perfil_id',
                'label' => 'lang:perfil_id',
                'rules' => 'required|integer|xss_clean'
            ],
            [
                'field' => 'sys_systemcode',
                'label' => 'lang:sys_systemcode',
                'rules' => 'required|onlyValidText|xss_clean|max_length[10]'
            ],
            [
                'field' => 'perfil_codigo',
                'label' => 'lang:perfil_codigo',
                'rules' => 'required|onlyValidText|xss_clean|max_length[15]'
            ],
            [
                'field' => 'perfil_descripcion',
                'label' => 'lang:perfil_descripcion',
                'rules' => 'required|onlyValidText|xss_clean|max_length[120]'
            ],
            [
                'field' => 'versionId',
                'label' => 'lang:versionId',
                'rules' => 'required|integer|xss_clean'
            ]
        ],
        'delPerfil' => [
            [
                'field' => 'perfil_id',
                'label' => 'lang:perfil_id',
                'rules' => 'required|integer|xss_clean'
            ],
            [
                'field' => 'versionId',
                'label' => 'lang:versionId',
                'rules' => 'required|integer|xss_clean'
            ]
        ],
        'addPerfil' => [
            [
                'field' => 'sys_systemcode',
                'label' => 'lang:sys_systemcode',
                'rules' => 'required|onlyValidText|xss_clean|max_length[10]'
            ],
            [
                'field' => 'perfil_codigo',
                'label' => 'lang:perfil_codigo',
                'rules' => 'required|onlyValidText|xss_clean|max_length[15]'
            ],
            [
                'field' => 'perfil_descripcion',
                'label' => 'lang:perfil_descripcion',
                'rules' => 'required|onlyValidText|xss_clean|max_length[120]'
            ]
        ]
    ];
?>