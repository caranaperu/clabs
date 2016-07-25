<?php
$config['v_ciudades'] = array(
    'getCiudades' => array(
        array(
            'field' => 'ciudades_codigo',
            'label' => 'lang:ciudades_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        )
    ),
    'updCiudades' => array(
        array(
            'field' => 'ciudades_codigo',
            'label' => 'lang:ciudades_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'ciudades_descripcion',
            'label' => 'lang:ciudades_descripcion',
            'rules' => 'required|xss_clean|max_length[120]'
        ),
        array(
            'field' => 'paises_codigo',
            'label' => 'lang:paises_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'ciudades_altura',
            'label' => 'lang:ciudades_altura',
            'rules' => 'required|is_bool|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delCiudades' => array(
        array(
            'field' => 'ciudades_codigo',
            'label' => 'lang:ciudades_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'addCiudades' => array(
        array(
            'field' => 'ciudades_codigo',
            'label' => 'lang:ciudades_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'ciudades_descripcion',
            'label' => 'lang:ciudades_descripcion',
            'rules' => 'required|xss_clean|max_length[120]'
        ),
        array(
            'field' => 'paises_codigo',
            'label' => 'lang:paises_codigo',
            'rules' => 'required|alpha_numeric|xss_clean|max_length[15]'
        ),
        array(
            'field' => 'ciudades_altura',
            'label' => 'lang:ciudades_altura',
            'rules' => 'required|is_bool|xss_clean'
        )
    )
);
?>