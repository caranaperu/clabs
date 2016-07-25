<?php

$config['v_tinsumo'] = array(
    'getTInsumo' => array(
        array(
            'field' => 'tinsumo_codigo',
            'label' => 'lang:tinsumo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        )
    ),
    'updTInsumo' => array(
        array(
            'field' => 'tinsumo_codigo',
            'label' => 'lang:tinsumo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'tinsumo_descripcion',
            'label' => 'lang:tinsumo_descripcion',
            'rules' => 'required|xss_clean|max_length[60]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delTInsumo' => array(
        array(
            'field' => 'tinsumo_codigo',
            'label' => 'lang:tinsumo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addTInsumo' => array(
              array(
            'field' => 'tinsumo_codigo',
            'label' => 'lang:tinsumo_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'tinsumo_descripcion',
            'label' => 'lang:tinsumo_descripcion',
            'rules' => 'required|xss_clean|max_length[60]'
        )
    )
);
?>