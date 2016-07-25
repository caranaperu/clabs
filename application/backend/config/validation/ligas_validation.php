<?php

$config['v_ligas'] = array(
    'getLigas' => array(
        array(
            'field' => 'ligas_codigo',
            'label' => 'lang:ligas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        )
    ),
    'updLigas' => array(
        array(
            'field' => 'ligas_codigo',
            'label' => 'lang:ligas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'ligas_descripcion',
            'label' => 'lang:ligas_descripcion',
            'rules' => 'required|xss_clean|max_length[120]'
        ),
        array(
            'field' => 'ligas_persona_contacto',
            'label' => 'lang:ligas_persona_contacto',
            'rules' => 'required|xss_clean|max_length[150]'
        ),
        array(
            'field' => 'ligas_direccion',
            'label' => 'lang:ligas_direccion',
            'rules' => 'required|xss_clean|max_length[250]'
        ),
        array(
            'field' => 'ligas_email',
            'label' => 'lang:ligas_email',
            'rules' => 'valid_email|xss_clean|max_length[150]'
        ),
        array(
            'field' => 'ligas_telefono_oficina',
            'label' => 'lang:ligas_telefono_oficina',
            'rules' => 'integer|xss_clean|min_length[7]|max_length[10]'
        ),
        array(
            'field' => 'ligas_telefono_celular',
            'label' => 'lang:ligas_telefono_celular',
            'rules' => 'integer|xss_clean|min_length[7]|max_length[10]'
        ),
        array(
            'field' => 'ligas_web_url',
            'label' => 'lang:ligas_web_url',
            'rules' => 'validateURL|xss_clean|max_length[250]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delLigas' => array(
        array(
            'field' => 'ligas_codigo',
            'label' => 'lang:ligas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addLigas' => array(
        array(
            'field' => 'ligas_codigo',
            'label' => 'lang:ligas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'ligas_descripcion',
            'label' => 'lang:ligas_descripcion',
            'rules' => 'required|xss_clean|max_length[120]'
        ),
        array(
            'field' => 'ligas_persona_contacto',
            'label' => 'lang:ligas_persona_contacto',
            'rules' => 'required|xss_clean|max_length[150]'
        ),
        array(
            'field' => 'ligas_direccion',
            'label' => 'lang:ligas_direccion',
            'rules' => 'required|xss_clean|max_length[250]'
        ),
        array(
            'field' => 'ligas_email',
            'label' => 'lang:ligas_email',
            'rules' => 'valid_email|xss_clean|max_length[150]'
        ),
        array(
            'field' => 'ligas_telefono_oficina',
            'label' => 'lang:ligas_telefono_oficina',
            'rules' => 'integer|xss_clean|min_length[7]|max_length[10]'
        ),
        array(
            'field' => 'ligas_telefono_celular',
            'label' => 'lang:ligas_telefono_celular',
            'rules' => 'integer|xss_clean|min_length[7]|max_length[10]'
        ),
        array(
            'field' => 'ligas_web_url',
            'label' => 'lang:ligas_web_url',
            'rules' => 'validateURL|xss_clean|max_length[250]'
        )
    )
);
?>