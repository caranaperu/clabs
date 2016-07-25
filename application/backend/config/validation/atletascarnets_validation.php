<?php

$config['v_atletascarnets'] = array(
    // Para la lectura de un contribuyente basado eb su id
    'getAtletasCarnets' => array(
        array(
            'field' => 'atletas_carnets_id',
            'label' => 'lang:atletas_carnets_id',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'updAtletasCarnets' => array(
        array(
            'field' => 'atletas_carnets_id',
            'label' => 'lang:atletas_carnets_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'atletas_carnets_numero',
            'label' => 'lang:atletas_carnets_numero',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[10]'
        ),
        array(
            'field' => 'atletas_codigo',
            'label' => 'lang:atletas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'atletas_carnets_agno',
            'label' => 'lang:atletas_carnets_agno',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'atletas_carnets_fecha',
            'label' => 'lang:atletas_carnets_fecha',
            'rules' => 'required|validDate|xss_clean'
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
    'delAtletasCarnets' => array(
        array(
            'field' => 'atletas_carnets_id',
            'label' => 'lang:atletas_carnets_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss'
        )
    ),
    'addAtletasCarnets' => array(
        array(
            'field' => 'atletas_carnets_numero',
            'label' => 'lang:atletas_carnets_numero',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[10]'
        ),
        array(
            'field' => 'atletas_codigo',
            'label' => 'lang:atletas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'atletas_carnets_agno',
            'label' => 'lang:atletas_carnets_agno',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'atletas_carnets_fecha',
            'label' => 'lang:atletas_carnets_fecha',
            'rules' => 'required|validDate|xss_clean'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_bool|xss_clean")'
        )
    )
);
?>