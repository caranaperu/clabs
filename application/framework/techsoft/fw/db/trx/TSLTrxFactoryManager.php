<?php

/**
 * Clase tipo factory que permite obtener referencia a Transaction Manager
 * de cada un de las bases de datos en uso.
 *
 * @author Carlos Arana Reategui
 * @version 1.00 , 27 MAY 2011
 * 
 * @since 1.00
 *
 */
class TSLTrxFactoryManager {

    /**
     * Guarda la instancia unica de esta clase.
     * 
     * @var TSLTrxFactoryManager $instance
     */
    private static $instance;

    /**
     * Arreglo que contiene todos los transaccion managers en uso.
     * @var array  $m_trxManagers
     */
    private $m_trxManagers = array();

    // The singleton method
    public static function instance() {
        if (!isset(self::$instance)) {
            $c = __CLASS__;
            self::$instance = new $c;
        }

        return self::$instance;
    }

    public function &getTrxManager($idDb=null) {
        $defaultDB = TSLUtilsHelper::getDefaultDatabase();
        // Si el parametros es null o no esta seteado tratamos de usar el active group.
        if (isset($idDb) == FALSE and isset($defaultDB)) {
            $idDb = $defaultDB;
        }


        if (!array_key_exists($idDb, $this->m_trxManagers)) {
            $this->m_trxManagers[$idDb] = new TSLTransactionManager($idDb);
        }
        return $this->m_trxManagers[$idDb];
    }

    // La instancia no pede ser clonada
    public function __clone() {
        trigger_error('Clone no esta permitida.', E_USER_ERROR);
    }

}

?>