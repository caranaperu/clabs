<?php

/**
 * Clase que implementa el transaction manager para las bases de
 * datos soportadas por CodeIgniter.
 *
 * @author Carlos Arana Reategui
 * @version 1.00 , 27 MAY 2011
 *
 * @since 1.00
 *
 */
class TSLTransactionManager implements TSLITransactionManager {

    /**
     * Se guarda el nombre identificador de la base de datos.
     * @var String $m_idDb
     */
    private $m_idDb;

    /**
     * Indica si la base de datos ya esta abierta.
     * @var boolean $isAlreadyOpened
     */
    private $isAlreadyOpened = false;

    /**
     * Indica si las operaciones seran bajo transaccion o no
     * @var boolean $isAutoTransactionEnabled
     */
    private $isAutoTransactionEnabled = false;

    /**
     * Pointer a la base de datos
     * @var DB $DB
     */
    private $DB;

    /**
     * Constructor
     * Si el paramero es null o no esta definido se tomara el rl aactive_group
     * definido en database.php
     *
     * @param type $idDb String que identifica a la db en database.php
     */
    public function __construct($idDb = null) {
        $defaultDB = TSLUtilsHelper::getDefaultDatabase();

        // Si el parametros es null o no esta seteado tratamos de usar el active group.
        if (isset($idDb) == FALSE and isset($defaultDB)) {
            $this->m_idDb = $defaultDB;
        } else {
            // De lo contrario tomamos como cierto el parametro.
            $this->m_idDb = $idDb;
        }
    }

    /*     * ******************************************
     *  METODOS DE CLASE
     * ******************************************* */

    /**
     * Si es TRUE las transacciones seran automaticamente manejadas,
     *
     * @param boolean $enableAutoTransactions
     */
    public function init($enableAutoTransactions = TRUE) {
        if ($this->isAlreadyOpened == FALSE) {
            $CI = & get_instance();
            
            // Modificacion : 17-09-2016
            // Dado que la base de datos puede ser abierta por otras librerias ahora se chequea tambien el estado
            // $this->DB el cual de ser null , asi este abierta la base de datos obligara a cargar la libreria
            // de base de datos o usar la ya existente.
            if ($this->DB and isset($CI->db) and (is_resource($CI->db->conn_id) OR is_object($CI->db->conn_id))) {
                $this->isAlreadyOpened = TRUE;
            } else {
                if (!$this->DB) {
                    if (isset($CI->db)) {
                        $this->DB = $CI->db;
                    } else {
                        $this->DB = $CI->load->database($this->m_idDb, TRUE);
                    }
                }
                // Por default modo estricto
                $this->DB->trans_strict(FALSE);
                // Conecto ?
                if (is_resource($this->DB->conn_id) OR is_object($this->DB->conn_id)) {
                    $this->isAlreadyOpened = TRUE;
                } else {
                    $this->isAlreadyOpened = FALSE;
                }
                $this->enableTransactionMode($enableAutoTransactions);
                $this->startTransaction();
            }
        }
    }

    public function startTransaction() {
        if ($this->isAutoTransactionEnabled) {
            $this->DB->trans_begin();
        }
    }

    public function endTransaction() {
        if ($this->isAutoTransactionEnabled) {
            if ($this->DB->trans_status() === FALSE) {
                $this->rollback();
            } else {
                $this->commit();
            }
        }
    }

    public function commit() {
        $this->DB->trans_commit();
    }

    public function rollback() {
        $this->DB->trans_rollback();
    }

    public function end() {
        if ($this->isAlreadyOpened === TRUE) {
            $this->endTransaction();
            $this->DB->close();
        }
        unset($this->DB);
        $this->isAlreadyOpened = FALSE;
    }

    public function &getDB() {
        return $this->DB;
    }

    public function isAlreadyOpened() {
        return $this->isAlreadyOpened;
    }

    public function enableTransactionMode($enable) {
        $this->isAutoTransactionEnabled = $enable;
    }

}
?>