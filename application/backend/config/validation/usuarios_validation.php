<?php

$config['v_usuarios'] = array(
    'getUsuarios' => array(
        array(
            'field' => 'usuarios_id',
            'label' => 'lang:usuarios_id',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'updUsuarios' => array(
        array(
            'field' => 'usuarios_id',
            'label' => 'lang:usuarios_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'usuarios_code',
            'label' => 'lang:usuarios_code',
            'rules' => 'required|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'usuarios_password',
            'label' => 'lang:usuarios_password',
            'rules' => 'required|xss_clean|max_length[20]'
        ),
        array(
            'field' => 'usuarios_nombre_completo',
            'label' => 'lang:usuarios_nombre_completo',
            'rules' => 'required|xss_clean|max_length[250]'
        ),
        array(
            'field' => 'usuarios_admin',
            'label' => 'lang:usuarios_admin',
            'rules' => 'required|xss_clean|is_bool'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delUsuarios' => array(
        array(
            'field' => 'usuarios_id',
            'label' => 'lang:usuarios_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addUsuarios' => array(
        array(
            'field' => 'usuarios_code',
            'label' => 'lang:usuarios_code',
            'rules' => 'required|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'usuarios_password',
            'label' => 'lang:usuarios_password',
            'rules' => 'required|xss_clean|max_length[20]'
        ),
        array(
            'field' => 'usuarios_nombre_completo',
            'label' => 'lang:usuarios_nombre_completo',
            'rules' => 'required|xss_clean|max_length[250]'
        ),
        array(
            'field' => 'usuarios_admin',
            'label' => 'lang:usuarios_admin',
            'rules' => 'required|xss_clean|is_bool'
        )
    )
);
?>