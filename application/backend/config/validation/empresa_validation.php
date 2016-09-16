<?php

$config['v_empresa'] = array(
    'getEmpresa' => array(
        array(
            'field' => 'empresa_id',
            'label' => 'lang:id',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'updEmpresa' => array(
        array(
            'field' => 'empresa_id',
            'label' => 'lang:id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'empresa_razon_social',
            'label' => 'lang:empresa_razon_social',
            'rules' => 'required|xss_clean|max_length[200]'
        ),
        array(
            'field' => 'tipo_empresa_codigo',
            'label' => 'lang:tipo_empresa_codigo',
            'rules' => 'required|xss_clean|max_length[3]'
        ),
        array(
            'field' => 'empresa_ruc',
            'label' => 'lang:empresa_ruc',
            'rules' => 'required|numeric|xss_clean|min_length[11]|max_length[11]'
        ),
        array(
            'field' => 'empresa_direccion',
            'label' => 'lang:empresa_direccion',
            'rules' => 'required|xss_clean|max_length[200]'
        ),
        array(
            'field' => 'empresa_correo',
            'label' => 'lang:empresa_correo',
            'rules' => 'valid_email|xss_clean|max_length[100]'
        ),
        array(
            'field' => 'empresa_fax',
            'label' => 'lang:empresa_fax',
            'rules' => 'integer|xss_clean|min_length[7]|max_length[10]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delEmpresa' => array(
        array(
            'field' => 'empresa_id',
            'label' => 'lang:id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addEmpresa' => array(
        array(
            'field' => 'empresa_razon_social',
            'label' => 'lang:empresa_razon_social',
            'rules' => 'required|xss_clean|max_length[200]'
        ),
        array(
            'field' => 'tipo_empresa_codigo',
            'label' => 'lang:tipo_empresa_codigo',
            'rules' => 'required|xss_clean|max_length[3]'
        ),
        array(
            'field' => 'empresa_ruc',
            'label' => 'lang:empresa_ruc',
            'rules' => 'required|numeric|xss_clean|min_length[11]|max_length[11]'
        ),
        array(
            'field' => 'empresa_direccion',
            'label' => 'lang:empresa_direccion',
            'rules' => 'required|xss_clean|max_length[200]'
        ),
        array(
            'field' => 'empresa_correo',
            'label' => 'lang:empresa_correo',
            'rules' => 'valid_email|xss_clean|max_length[100]'
        ),
        array(
            'field' => 'empresa_fax',
            'label' => 'lang:empresa_fax',
            'rules' => 'integer|xss_clean|min_length[7]|max_length[10]'
        )
    )
);
?>