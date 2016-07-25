<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Este DAO basico sirve para los casos simples de hacer operaciones CRUD a modelos
 * del sistema, basicamente es usable cuando la entidad = modelo.
 * Recordar que es abstracta y que deben implementarse las clases que retornan los  querys
 * para las distintas operaciones.
 *
 * IMPORTANTE :
 * La aplicacion debera haber cargado previamente las siguientes definiciones
 *
 *
 *       define('DB_OP_OK',0);
 *       define('DB_ERR_ALLOK',-100000);
 *       define('DB_ERR_SERVERNOTFOUND',-100001);
 *       define('DB_ERR_RECORDNOTFOUND',-100002);
 *       define('DB_ERR_RECORDNOTDELETED',-100003);
 *       define('DB_ERR_RECORDEXIST',-100004);
 *       define('DB_ERR_FOREIGNKEY',-100005);
 *       define('DB_ERR_CANTEXECUTE',-100006);
 *       define('DB_ERR_RECORD_MODIFIED',-100007);
 *       define('DB_ERR_RECORDINACTIVE',-100008);
 *       define('DB_ERR_DUPLICATEKEY',-100009);
 *
 * @author Carlos Arana Reategui
 * @version $Id: TSLBasicRecordDAO.php 191 2014-06-23 19:48:07Z aranape $
 * @since 08-AGO-2012
 * @history 10/08/13 Se agrego soporte para foreign key
 *
 * 18 JUL 2016 Se agrego a los metodos get,add y update el parametro $subOperation por si se requiriera
 * acciones especiales durante una de estas operaciones basado en las operaciones a realizar.
 * Un ejemplo seria que get pueda leer los datos de acuerdo al modelo fisico o haciendo un join
 * para retornar un registro con valores consolidado.
 *
 * $Author: aranape $
 * $Date: 2014-06-23 14:48:07 -0500 (lun, 23 jun 2014) $
 * $Rev: 191 $
 *
 * @abstract
 */
abstract class TSLBasicRecordDAO implements TSLIBasicRecordDAO {

    /**
     * Si la busqueda permite solo activos o no,
     * @var boolean TRUE solo se buscara activos
     */
    protected $activeSearchOnly = TRUE;

    /**
     * Busca un record basado en su id.
     *
     * @see \shared\dao\defs\ITipoContribuyenteDAO::get()
     */
    public function get($id, \TSLDataModel &$model, $subOperation = NULL) {
        $localTrans = FALSE;
        $ret = DB_ERR_ALLOK;

        $tmg = \TSLTrxFactoryManager::instance()->getTrxManager();
        if ($tmg->isAlreadyOpened() == FALSE) {
            $tmg->init();
            if ($tmg->isAlreadyOpened() == FALSE) {
                $ret = DB_ERR_SERVERNOTFOUND;
            } else {
                $localTrans = TRUE;
            }
        }

        if ($ret == DB_ERR_ALLOK) {
            $DB = $tmg->getDB();

            $query = $DB->query($this->getRecordQuery($id, $subOperation));

            if (!$query) {
                $ret = DB_ERR_CANTEXECUTE;
                //echo $DB->_error_message();
            } else {
                // Si encuentro un registro pero el falg se busqueda de activos
                // esta encendido
                if ($query->num_rows() === 1) {
                    $row = $query->row_array();
                    // Copio los resultados al modelo.
                    $model->setOptions($row);

                    //
                    if ($this->activeSearchOnly == TRUE && $model->getActivo() == FALSE) {
                        $ret = DB_ERR_RECORDINACTIVE;
                    }
                } else {
                    $ret = DB_ERR_RECORDNOTFOUND;
                }
                $query->free_result();
                unset($query);
            }
        }

        if ($ret != DB_ERR_ALLOK && $ret != DB_ERR_RECORDNOTFOUND && $ret != DB_ERR_RECORDINACTIVE) {
            throw new \TSLDbException($ret == DB_ERR_CANTEXECUTE ? $DB->_error_message() : null, $ret);
        }

        return $ret;
    }

    /**
     * Busca un record basado en su codigo unico.
     *
     * @see \TSLIBasicRecordDAO::getByCode()
     */
    public function getByCode($code, \TSLDataModel &$model, $subOperation = NULL) {
        $localTrans = FALSE;
        $ret = DB_ERR_ALLOK;

        $tmg = \TSLTrxFactoryManager::instance()->getTrxManager();
        if ($tmg->isAlreadyOpened() == FALSE) {
            $tmg->init();
            if ($tmg->isAlreadyOpened() == FALSE) {
                $ret = DB_ERR_SERVERNOTFOUND;
            } else {
                $localTrans = TRUE;
            }
        }

        if ($ret == DB_ERR_ALLOK) {
            $DB = $tmg->getDB();

            $query = $DB->query($this->getRecordQueryByCode($code, $subOperation));

            if (!$query) {
                $ret = DB_ERR_CANTEXECUTE;
                //echo $DB->_error_message();
            } else {
                // Si encuentro un registro pero el falg se busqueda de activos
                // esta encendido
                if ($query->num_rows() === 1) {
                    $row = $query->row_array();
                    // Copio los resultados al modelo.
                    $model->setOptions($row);

                    //
                    if ($this->activeSearchOnly == TRUE && $model->getActivo() == FALSE) {
                        $ret = DB_ERR_RECORDINACTIVE;
                    }
                } else {
                    $ret = DB_ERR_RECORDNOTFOUND;
                }
                $query->free_result();
                unset($query);
            }
        }

        if ($localTrans == TRUE) {
            $tmg->end();
        }
        if ($ret != DB_ERR_ALLOK && $ret != DB_ERR_RECORDNOTFOUND && $ret != DB_ERR_RECORDINACTIVE) {
            throw new \TSLDbException($ret == DB_ERR_CANTEXECUTE ? $DB->_error_message() : null, $ret);
        }

        return $ret;
    }

    /**
     * Funcion que lee la lista de todos los modelos que implemente la clase
     * final.
     *
     * @see TSLIBasicRecordDAO::fetch()
     *
     */
    public function fetch(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        $localTrans = FALSE;
        $ret = DB_ERR_ALLOK;
        $results = array();


        $tmg = \TSLTrxFactoryManager::instance()->getTrxManager();
        if ($tmg->isAlreadyOpened() == FALSE) {
            $tmg->init();
            if ($tmg->isAlreadyOpened() == FALSE) {
                $ret = DB_ERR_SERVERNOTFOUND;
            } else {
                $localTrans = TRUE;
            }
        }

        if ($ret == DB_ERR_ALLOK) {
            $DB = $tmg->getDB();

            $query = $DB->query($this->getFetchQuery($record, $constraints, $subOperation));
            if (!$query) {
                $ret = DB_ERR_CANTEXECUTE;
                // echo $DB->_error_message();
            } else {
                if ($query->num_rows() > 0) {
                    foreach ($query->result_array() as $row) {
                        //Seteamos los valores de la base en el modelo.
                        $results[] = $row;
                        $row = null;
                    }
                }
                $query->free_result();
                unset($query);
            }
        }
        if ($localTrans == TRUE) {
            $tmg->end();
        }

        if ($ret != DB_ERR_ALLOK) {
            throw new \TSLDbException($ret == DB_ERR_CANTEXECUTE ? $DB->_error_message() : null, $ret);
        }
        return $results;
    }

    /**
     * Elimina un modelo de la persistencia.
     *
     * @see TSLIBasicRecordDAO::remove()
     *
     */
    public function remove($id, $versionId, $verifiedDeletedCheck) {
        $localTrans = FALSE;
        $ret = DB_ERR_ALLOK;

        $tmg = \TSLTrxFactoryManager::instance()->getTrxManager();
        if ($tmg->isAlreadyOpened() == FALSE) {
            $tmg->init();
            if ($tmg->isAlreadyOpened() == FALSE) {
                $ret = DB_ERR_SERVERNOTFOUND;
            } else {
                $localTrans = TRUE;
            }
        }

        if ($ret == DB_ERR_ALLOK) {
            $DB = $tmg->getDB();

            // eliminado de registor.
            $query = $DB->query($this->getDeleteRecordQuery($id, $versionId));

            if (!$query) {
                if ($this->isForeignKeyError($DB->_error_number(), $DB->_error_message()) == TRUE) {
                    $ret = DB_ERR_FOREIGNKEY;
                } else {
                    $ret = DB_ERR_CANTEXECUTE;
                }
            } else {
                // verifico si se chequea si ya esta eliminado
                if ($verifiedDeletedCheck === TRUE) {
                    // Si el numero de filas es menor o iual que cero , el registro esta modificado o no existe por haber sido
                    // eliminado.
                    if ($DB->affected_rows() <= 0) {
                        $ret = DB_ERR_RECORDNOTFOUND;
                    }
                }
                //  $query->free_result();
                unset($query);
            }
        }
        if ($localTrans == TRUE) {
            $tmg->end();
        }

        if ($ret != DB_ERR_ALLOK && $ret != DB_ERR_RECORDNOTFOUND && $ret != DB_ERR_FOREIGNKEY) {
            throw new \TSLDbException($ret == DB_ERR_CANTEXECUTE ? $DB->_error_message() : null, $ret);
        }

        return $ret;
    }

    /**
     * Ipdate un registro a la persistencia.
     *
     * @see TSLIBasicRecordDAO::update()
     *
     */
    public function update(\TSLDataModel &$record, $subOperation = NULL) {
        $localTrans = FALSE;
        $ret = DB_ERR_ALLOK;

        $tmg = \TSLTrxFactoryManager::instance()->getTrxManager();
        if ($tmg->isAlreadyOpened() == FALSE) {
            $tmg->init();
            if ($tmg->isAlreadyOpened() == FALSE) {
                $ret = DB_ERR_SERVERNOTFOUND;
            } else {
                $localTrans = TRUE;
            }
        }

        if ($ret == DB_ERR_ALLOK) {
            $DB = $tmg->getDB();

            // Trata de hacer update .
            $query = $DB->query($this->getUpdateRecordQuery($record));
            if (!$query) {
                // Se busca si es llave duplicada en el caso que otros campos no la llave (ya que es un update)
                // que tengan unique constraint han rechazado el update.
                if ($this->isDuplicateKeyError($DB->_error_number(), $DB->_error_message()) == TRUE) {
                    $ret = DB_ERR_DUPLICATEKEY;
                } else if ($this->isForeignKeyError($DB->_error_number(), $DB->_error_message()) == TRUE) {
                    $ret = DB_ERR_FOREIGNKEY;
                } else if ($this->isRecordModifiedError($DB->_error_number(), $DB->_error_message()) == TRUE) {
                    $ret = DB_ERR_RECORD_MODIFIED;
                } else {
                    $ret = DB_ERR_CANTEXECUTE;
                }
            } else {
                // Si el update no se realizo es porque el registro ha sido eliminado o modificado
                if ($DB->affected_rows() <= 0) {
                    // Tratamos de leer para ver si esta solo modificado o ha sido eliminado.
                    try {
                        // Aqui leemos de no exister recibiremos DB_ERR_RECORDNOTFOUND
                        // de lo contrario DB_ERR_ALLOK
                        $ret = $this->get($record->getId(), $record);
                        if ($ret == DB_ERR_ALLOK) {
                            $ret = DB_ERR_RECORD_MODIFIED;
                        }
                    } catch (Exception $ex) {
                        $ret = $ex->getCode();
                    }
                } else {
                    unset($query);

                    // De lo contrario actualizamos el registro con los valores actualizados
                    // esto ya que la version del record cambiara y debe ser actualizado por el
                    // lado cliente si lo cree conveniente.
                    try {
                        // Aqui leemos de no exister recibiremos DB_ERR_RECORDNOTFOUND
                        // de lo contrario DB_ERR_ALLOK
                        $ret = $this->get($record->getId(), $record, $subOperation );
                    } catch (Exception $ex) {
                        $ret = $ex->getCode();
                    }
                }

                unset($query);
            }
        }

        if ($localTrans == TRUE) {
            $tmg->end();
        }

        if ($ret != DB_ERR_ALLOK && $ret != DB_ERR_RECORD_MODIFIED && $ret != DB_ERR_RECORDNOTFOUND && $ret != DB_ERR_RECORDINACTIVE && $ret != DB_ERR_FOREIGNKEY && $ret != DB_ERR_DUPLICATEKEY) {
            throw new \TSLDbException($ret == DB_ERR_CANTEXECUTE ? $DB->_error_message() : null, $ret);
        }

        return $ret;
    }

    /**
     * Agrega un registro a la persistencia.
     *
     * @see TSLIBasicRecordDAO::add()
     *
     */
    public function add(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL) {
        $localTrans = FALSE;
        $ret = DB_ERR_ALLOK;
        $needRereadRecord = FALSE;

        $tmg = \TSLTrxFactoryManager::instance()->getTrxManager();
        if ($tmg->isAlreadyOpened() == FALSE) {
            $tmg->init();
            if ($tmg->isAlreadyOpened() == FALSE) {
                $ret = DB_ERR_SERVERNOTFOUND;
            } else {
                $localTrans = TRUE;
            }
        }

        $uniqueId = $record->getUniqueCode();

        if ($ret === DB_ERR_ALLOK) {
            try {
                // Aqui leemos de no exister recibiremos DB_ERR_RECORDNOTFOUND
                // de lo contrario DB_ERR_ALLOK
                // Logicamente si existe un id es casi seguro el registro ya existe
                // pero verificamos ya que podria estar eliminado entre el momento que se
                // leyo y el momento que se graba. Aqui se necesita lectura del modelo fisico
                // por ende no enviamos la sub operacion.
                if ($uniqueId != NULL) {
                    $ret = $this->getByCode($uniqueId, $record);
                    if ($ret == DB_ERR_ALLOK) {
                        $ret = DB_ERR_RECORDEXIST;
                    }
                } else {
                    $ret = DB_ERR_RECORDNOTFOUND;
                }
            } catch (Exception $ex) {
                $ret = $ex->getCode();
            }
            // Aqui para el caso exista una excepcion
            $DB = $tmg->getDB();

            // Si no existe , continuamos.
            if ($ret == DB_ERR_RECORDNOTFOUND) {
                $ret = DB_ERR_ALLOK;


                try {
                    // Trata de hacer update.
                    $query = $DB->query($this->getAddRecordQuery($record, $constraints));
                    if (!$query) {
                        if ($this->isDuplicateKeyError($DB->_error_number(), $DB->_error_message()) == TRUE) {
                            $ret = DB_ERR_RECORDEXIST;
                            //    $needRereadRecord = TRUE;
                        } else if ($this->isForeignKeyError($DB->_error_number(), $DB->_error_message()) == TRUE) {
                            $ret = DB_ERR_FOREIGNKEY;
                        } else {
                            $ret = DB_ERR_CANTEXECUTE;
                        }
                    }
                    unset($query);
                } catch (Exception $ex) {
                    $ret = $ex->getCode();
                }

                // Si no hay error o se requiere releer el registro , leemos y seteamos los ultimos valores
                if ($ret == DB_ERR_ALLOK || $needRereadRecord == TRUE) {
                    // De lo contrario actualizamos el registro con los valores actualizados
                    // esto ya que la version del record cambiara y debe ser actualizado por el
                    // lado cliente si lo cree conveniente.
                    try {
                        // Si la llave primaria es una secuencia o identidad obtenemos el ultimo valor agregado.
                        // para ser colocado en la variable uniqueId, se supone que si el caso es que usa secuencias
                        // DEBERA EXISTIR AL MENOS UNA FILA CON RESULTADOS DE NO SER ASI DARA ERROR
                        //Previamente se verifica si no se tiene ya el unique id en el cso que se trate de agregar
                        // un registro PREEXISTENTE.
                        if ($needRereadRecord === FALSE && (!isset($uniqueId) || $uniqueId === NULL)) {
                            if ($record->isPKSequenceOrIdentity() === true) {
                                $query = $DB->query($this->getLastSequenceOrIdentityQuery($record));
                                // No puede ser mas de un record !!!!
                                if ($query && $query->num_rows() === 1) {
                                    $row = $query->first_row('array');
                                    foreach ($row as $x => $x_value) {
                                        $uniqueId = $row[$x];
                                    }
                                    unset($query);
                                }
                            }
                        }
                        // Aqui leemos de no exister recibiremos DB_ERR_RECORDNOTFOUND
                        // de lo contrario DB_ERR_ALLOK
                        $ret = $this->getByCode($uniqueId, $record, $subOperation );
                    } catch (Exception $ex) {
                        $ret = $ex->getCode();
                    }
                }
            }

            if ($localTrans == TRUE) {
                $tmg->end();
            }

            if ($ret != DB_ERR_ALLOK && $ret != DB_ERR_RECORDEXIST && $ret != DB_ERR_RECORDINACTIVE && $ret != DB_ERR_FOREIGNKEY) {
                throw new \TSLDbException($ret == DB_ERR_CANTEXECUTE ? $DB->_error_message() . '-' . $DB->_error_number() : null, $ret);
            }

            return $ret;
        }
    }

    /**
     * Debe retornar el string con el query para leer el registro
     * identificado por su id unico.
     *
     * @param mixed $id El identificador unico del registro.
     * @param string $subOperation para el caso que no se requiera la lectura directa del modelo
     * fisico y se requiera por ejemplo joins para normalizar la data a retornar, por default
     * leera el modelo fisico,
     *
     * @return String con el query requerido,
     * @abstract
     */
    abstract protected function getRecordQuery($id, $subOperation = NULL);

    /**
     * Debe retornar el string con el query para leer el registro
     * identificado por su codigo unico , esto es para el caso
     * que el id no sea la llave de busqueda.
     *
     * @param mixed $id El identificador unico del registro.
     * @param string $subOperation para el caso que no se requiera la lectura directa del modelo
     * fisico y se requiera por ejemplo joins para normalizar la data a retornar, por default
     * leera el modelo fisico,
     *
     * @return String con el query requerido,
     * @abstract
     */
    abstract protected function getRecordQueryByCode($code, $subOperation = NULL);

    /**
     * Debe retornar el query para recibir todos los registros, si el miembor
     * activeSearchOnly es TRUE solo buscara los activos
     *
     * @param \TSLDataModel $record El modelo de datos que contiene los datos
     * a buscar.
     * @param \TSLRequestConstraints $constraints conteniendo el numero de registros
     * elementos para el order by , filtro etc de la lista.
     *
     * @param string $subOperation si el caso de fetch de datos tiene sub operaciones
     *  que realizar, es comun en el fetch que existan variantes para una misma entidad
     *  ya que en uchos casos se reuiere joins para devolver una lista de registros de
     *  modelo no fisico.
     *
     * @return string String con el query requerido
     * @abstract
     */
    abstract protected function getFetchQuery(\TSLDataModel &$record = NULL, \TSLRequestConstraints &$constraints = NULL, $subOperation = NULL);

    /**
     * Debe retornar el query para eliminar un registro.
     *
     * @param mixed $id El identificacor unico del registro a eliminar.
     * @param int $versionId Para las bases de datos que soporten versionamiento
     * de registros este seria el valor de la version del registro.
     *
     * @return string Un string con el query requerido.
     * @abstract
     */
    abstract protected function getDeleteRecordQuery($id, $versionId);

    /**
     * Debe retornar el query requerido para actualizar un registro.
     *
     * @param \TSLDataModel $record El modelo de datos que representa al registro
     *  a actualizar.
     * @return string Un string con el query requerido.
     * @abstract
     */
    abstract protected function getUpdateRecordQuery(\TSLDataModel &$record);

    /**
     * Retorna el query para agregar un registro.
     *
     * @param \TSLDataModel $record El modelo de datos que representa al registro
     *  a agregar
     * @param \TSLRequestConstraints $constraints conteniendo data adicional para agregar
     * un registro , por ejemplo agregar un registro basado en los datos de otro codigo o cosas asi.
     *
     * @return string Un string con el query requerido.
     * @abstract
     */
    abstract protected function getAddRecordQuery(\TSLDataModel &$record, \TSLRequestConstraints &$constraints = NULL);

    /**
     * Si el modelo usara una pk o id que es secuencia o identidad
     * esta funcion debera estar implementada y debera retornar
     * el query que la base de datos requiere para obtener el ultimo valor
     * de una secuencia o campo identidad , esto varia mucho entre
     * bases de datos por lo tanto si se requiere debe hacerse override a este metodo
     * Por default retorna null.
     *
     * Por lo general usado siempre luego de un INSERT que es el unico caso en que
     * no se conoce su valor.
     *
     * Un caso especial es cuando un stored procedure agrega varias registros a la misma tabla
     * principal que corresponde al modelo , en ese caso no se puede jalar directamente el ultimo.
     * En dichos caso es conveniente que el override de este metodo retorne el query necesario
     * para obtener el id requerido basandose en el parametro record para obtener los datos.
     *
     * @param \TSLDataModel $record Datos del ultimo registro grabado tal como se enviaron
     * a grabar , usado para los casos que sea conveniente obtener un identity a partir de los datos
     * de entrada , como se explica en la ultima parte de los comentarios.
     *
     * @return null
     */
    protected function getLastSequenceOrIdentityQuery(\TSLDataModel &$record = NULL) {
        return NULL;
    }

}
?>