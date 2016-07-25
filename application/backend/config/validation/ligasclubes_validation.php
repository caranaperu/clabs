<?php

$config['v_ligasclubes'] = array(
    // Para la lectura de un contribuyente basado eb su id
    'getLigasClubes' => array(
        array(
            'field' => 'ligasclubes_id',
            'label' => 'lang:ligasclubes_id',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'updLigasClubes' => array(
        array(
            'field' => 'ligasclubes_id',
            'label' => 'lang:ligasclubes_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'ligas_codigo',
            'label' => 'lang:ligas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'clubes_codigo',
            'label' => 'lang:clubes_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'ligasclubes_desde',
            'label' => 'lang:ligasclubes_desde',
            'rules' => 'required|validDate|xss_clean'
        ),
        array(
            'field' => 'ligasclubes_hasta',
            'label' => 'lang:ligasclubes_hasta',
            'rules' => 'validDate|xss_clean|isFuture_date[ligasclubes_desde]'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_bool|xss_clean")'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss_clean'
        )
    ),
    'delLigasClubes' => array(
        array(
            'field' => 'ligasclubes_id',
            'label' => 'lang:ligasclubes_id',
            'rules' => 'required|integer|xss_clean'
        ),
        array(
            'field' => 'versionId',
            'label' => 'lang:versionId',
            'rules' => 'required|integer|xss'
        )
    ),
    'addLigasClubes' => array(
        array(
            'field' => 'ligas_codigo',
            'label' => 'lang:ligas_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'clubes_codigo',
            'label' => 'lang:clubes_codigo',
            'rules' => 'required|alpha_numeric|xss_clean||max_length[15]'
        ),
        array(
            'field' => 'ligasclubes_desde',
            'label' => 'lang:ligasclubes_desde',
            'rules' => 'required|validDate|xss_clean'
        ),
        array(
            'field' => 'ligasclubes_hasta',
            'label' => 'lang:ligasclubes_hasta',
            'rules' => 'validDate|xss_clean|isFuture_date[ligasclubes_desde]'
        ),
        array(
            'field' => 'activo',
            'label' => 'lang:activo',
            'rules' => 'is_bool|xss_clean")'
        )
    )
);
?>