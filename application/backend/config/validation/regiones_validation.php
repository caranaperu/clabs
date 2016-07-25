<?php

$config['v_regiones'] = array(
    'getRegiones' => array(
        array(
            'field' => 'regiones_codigo',
            'label' => 'lang:regiones_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        )
    ),
    'updRegiones' => array(
        array(
            'field' => 'regiones_codigo',
            'label' => 'lang:regiones_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'regiones_descripcion',
            'label' => 'lang:regiones_descripcion',
            'rules' => 'required|xss_clean|max_length[120]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delRegiones' => array(
        array(
            'field' => 'regiones_codigo',
            'label' => 'lang:regiones_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addRegiones' => array(
              array(
            'field' => 'regiones_codigo',
            'label' => 'lang:regiones_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'regiones_descripcion',
            'label' => 'lang:regiones_descripcion',
            'rules' => 'required|xss_clean|max_length[120]'
        )
    )
);
?>