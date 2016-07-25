<?php

$config['v_tcostos'] = array(
    'getTCostos' => array(
        array(
            'field' => 'tcostos_codigo',
            'label' => 'lang:tcosots_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[5]'
        )
    ),
    'updTCostos' => array(
        array(
            'field' => 'tcostos_codigo',
            'label' => 'lang:tcostos_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[5]'
        ),
        array(
            'field' => 'tcostos_descripcion',
            'label' => 'lang:tcostos_descripcion',
            'rules' => 'required|xss_clean|max_length[60]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delTCostos' => array(
        array(
            'field' => 'tcostos_codigo',
            'label' => 'lang:tcostos_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[5]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addTCostos' => array(
              array(
            'field' => 'tcostos_codigo',
            'label' => 'lang:tcostos_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[5]'
        ),
        array(
            'field' => 'tcostos_descripcion',
            'label' => 'lang:tcostos_descripcion',
            'rules' => 'required|xss_clean|max_length[60]'
        )
    )
);
?>