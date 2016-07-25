<?php

$config['v_clubesatletas'] = array(
    // Para la lectura de un contribuyente basado eb su id
    'getClubesAtletas' => array(
        array(
            'field' => 'clubesatletas_id',
            'label' => 'lang:clubesatletas_id',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'updClubesAtletas' => array(
        array(
            'field' => 'clubesatletas_id',
            'label' => 'lang:clubesatletas_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'clubes_codigo',
            'label' => 'lang:clubes_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'atletas_codigo',
            'label' => 'lang:atletas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'clubesatletas_desde',
            'label' => 'lang:clubesatletas_desde',
            'rules' => 'required|validDate|xss_clean'
        ),
        array(
            'field' => 'clubesatletas_hasta',
            'label' => 'lang:clubesatletas_hasta',
            'rules' => 'validDate|xss_clean|isFuture_date[clubesatletas_desde]'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_bool|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delClubesAtletas' => array(
        array(
            'field' => 'clubesatletas_id',
            'label' => 'lang:clubesatletas_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss'
        )
    ),
    'addClubesAtletas' => array(
        array(
            'field' => 'clubes_codigo',
            'label' => 'lang:clubes_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'atletas_codigo',
            'label' => 'lang:atletas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'clubesatletas_desde',
            'label' => 'lang:clubesatletas_desde',
            'rules' => 'required|validDate|xss_clean'
        ),
        array(
            'field' => 'clubesatletas_hasta',
            'label' => 'lang:clubesatletas_hasta',
            'rules' => 'validDate|xss_clean|isFuture_date[clubesatletas_desde]'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_bool|xss_clean")'
        )
    )
);
?>