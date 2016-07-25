<?php

$config['v_appcategorias'] = array(
    'getAppCategorias' => array(
        array(
            'field' => 'appcat_codigo',
            'label' => 'lang:appcat_codigo',
            'rules' => 'required|alpha|xss_clean||max_length[3]'
        )
    )

);
?>