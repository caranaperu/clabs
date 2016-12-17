<?php

$config['v_cliente'] = array(
    'getCliente' => array(
        array(
            'field' => 'cliente_id',
            'label' => 'lang:id',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'updCliente' => array(
        array(
            'field' => 'cliente_id',
            'label' => 'lang:id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'empresa_id',
            'label' => 'lang:empresa_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'cliente_razon_social',
            'label' => 'lang:cliente_razon_social',
            'rules' => 'required|xss_clean|max_length[200]'
        ),
        array(
            'field' => 'tipo_cliente_codigo',
            'label' => 'lang:tipo_cliente_codigo',
            'rules' => 'required|xss_clean|max_length[3]'
        ),
        array(
            'field' => 'cliente_ruc',
            'label' => 'lang:cliente_ruc',
            'rules' => 'required|numeric|xss_clean|min_length[11]|max_length[11]'
        ),
        array(
            'field' => 'cliente_direccion',
            'label' => 'lang:cliente_direccion',
            'rules' => 'required|xss_clean|max_length[200]'
        ),
        array(
            'field' => 'cliente_correo',
            'label' => 'lang:cliente_correo',
            'rules' => 'valid_email|xss_clean|max_length[100]'
        ),
        array(
            'field' => 'cliente_fax',
            'label' => 'lang:cliente_fax',
            'rules' => 'integer|xss_clean|min_length[7]|max_length[10]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delCliente' => array(
        array(
            'field' => 'cliente_id',
            'label' => 'lang:id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addCliente' => array(
        array(
            'field' => 'empresa_id',
            'label' => 'lang:empresa_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'cliente_razon_social',
            'label' => 'lang:cliente_razon_social',
            'rules' => 'required|xss_clean|max_length[200]'
        ),
        array(
            'field' => 'tipo_cliente_codigo',
            'label' => 'lang:tipo_cliente_codigo',
            'rules' => 'required|xss_clean|max_length[3]'
        ),
        array(
            'field' => 'cliente_ruc',
            'label' => 'lang:cliente_ruc',
            'rules' => 'required|numeric|xss_clean|min_length[11]|max_length[11]'
        ),
        array(
            'field' => 'cliente_direccion',
            'label' => 'lang:cliente_direccion',
            'rules' => 'required|xss_clean|max_length[200]'
        ),
        array(
            'field' => 'cliente_correo',
            'label' => 'lang:cliente_correo',
            'rules' => 'valid_email|xss_clean|max_length[100]'
        ),
        array(
            'field' => 'cliente_fax',
            'label' => 'lang:cliente_fax',
            'rules' => 'integer|xss_clean|min_length[7]|max_length[10]'
        )
    )
);
?>