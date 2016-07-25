<?php

$config['v_clubes'] = array(
    'getClubes' => array(
        array(
            'field' => 'clubes_codigo',
            'label' => 'lang:clubes_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        )
    ),
    'updClubes' => array(
        array(
            'field' => 'clubes_codigo',
            'label' => 'lang:clubes_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'clubes_descripcion',
            'label' => 'lang:clubes_descripcion',
            'rules' => 'required|xss_clean|max_length[120]'
        ),
       array(
            'field' => 'clubes_persona_contacto',
            'label' => 'lang:clubes_persona_contacto',
            'rules' => 'required|xss_clean|max_length[150]'
        ),
        array(
            'field' => 'clubes_direccion',
            'label' => 'lang:clubes_direccion',
            'rules' => 'required|xss_clean|max_length[250]'
        ),
        array(
            'field' => 'clubes_email',
            'label' => 'lang:clubes_email',
            'rules' => 'valid_email|xss_clean|max_length[150]'
        ),
        array(
            'field' => 'clubes_telefono_oficina',
            'label' => 'lang:clubes_telefono_oficina',
            'rules' => 'integer|xss_clean|min_length[7]|max_length[10]'
        ),
        array(
            'field' => 'clubes_telefono_celular',
            'label' => 'lang:clubes_telefono_celular',
            'rules' => 'integer|xss_clean|min_length[7]|max_length[10]'
        ),
        array(
            'field' => 'clubes_web_url',
            'label' => 'lang:clubes_web_url',
            'rules' => 'validateURL|xss_clean|max_length[250]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delClubes' => array(
        array(
            'field' => 'clubes_codigo',
            'label' => 'lang:clubes_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addClubes' => array(
        array(
            'field' => 'clubes_codigo',
            'label' => 'lang:clubes_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'clubes_descripcion',
            'label' => 'lang:clubes_descripcion',
            'rules' => 'required|xss_clean|max_length[120]'
        ),
               array(
            'field' => 'clubes_persona_contacto',
            'label' => 'lang:clubes_persona_contacto',
            'rules' => 'required|xss_clean|max_length[150]'
        ),
        array(
            'field' => 'clubes_direccion',
            'label' => 'lang:clubes_direccion',
            'rules' => 'required|xss_clean|max_length[250]'
        ),
        array(
            'field' => 'clubes_email',
            'label' => 'lang:clubes_email',
            'rules' => 'valid_email|xss_clean|max_length[150]'
        ),
        array(
            'field' => 'clubes_telefono_oficina',
            'label' => 'lang:clubes_telefono_oficina',
            'rules' => 'integer|xss_clean|min_length[7]|max_length[10]'
        ),
        array(
            'field' => 'clubes_telefono_celular',
            'label' => 'lang:clubes_telefono_celular',
            'rules' => 'integer|xss_clean|min_length[7]|max_length[10]'
        ),
        array(
            'field' => 'clubes_web_url',
            'label' => 'lang:clubes_web_url',
            'rules' => 'validateURL|xss_clean|max_length[250]'
        )
    )
);
?>