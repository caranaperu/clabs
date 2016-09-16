<?php

$config['vtipo_empresa_'] = array(
    'getTipoEmprersa' => array(
        array(
            'field' => 'tipo_empresa_codigo',
            'label' => 'lang:tipo_empresa_codigo',
            'rules' => 'required|alpha|xss_clean||max_length[3]'
        )
    ),
    'updTipoEmprersa' => array(
        array(
            'field' => 'tipo_empresa_codigo',
            'label' => 'lang:tipo_empresa_codigo',
            'rules' => 'required|alpha|xss_clean|max_length[3]'
        ),
        array(
            'field' => 'tipo_empresa_descripcion',
            'label' => 'lang:tipo_empresa_descripcion',
            'rules' => 'required|xss_clean|max_length[120]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delTipoEmprersa' => array(
        array(
            'field' => 'tipo_empresa_codigo',
            'label' => 'lang:tipo_empresa_codigo',
            'rules' => 'required|alpha|xss_clean|max_length[3]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addTipoEmprersa' => array(
        array(
            'field' => 'tipo_empresa_codigo',
            'label' => 'lang:tipo_empresa_codigo',
            'rules' => 'required|alpha|xss_clean|max_length[3]'
        ),
        array(
            'field' => 'tipo_empresa_descripcion',
            'label' => 'lang:tipo_empresa_descripcion',
            'rules' => 'required|xss_clean|max_length[120]'
        )
    )
);
?>