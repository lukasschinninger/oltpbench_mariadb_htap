/******************************************************************************
 *  Copyright 2015 by OLTPBenchmark Project                                   *
 *                                                                            *
 *  Licensed under the Apache License, Version 2.0 (the "License");           *
 *  you may not use this file except in compliance with the License.          *
 *  You may obtain a copy of the License at                                   *
 *                                                                            *
 *    http://www.apache.org/licenses/LICENSE-2.0                              *
 *                                                                            *
 *  Unless required by applicable law or agreed to in writing, software       *
 *  distributed under the License is distributed on an "AS IS" BASIS,         *
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  *
 *  See the License for the specific language governing permissions and       *
 *  limitations under the License.                                            *
 ******************************************************************************/

package com.oltpbenchmark.benchmarks.chbenchmark.queries;

import com.oltpbenchmark.api.SQLStmt;
import com.oltpbenchmark.benchmarks.chbenchmark.*;

public class Q20 extends GenericQuery {

    public final SQLStmt query_stmt = new SQLStmt(
            "SELECT su_name, "
                    + "su_address "
                    + "FROM supplier, "
                    + CHBenCHmark.TABLE + ".nation "
                    + "WHERE su_suppkey IN "
                    + "(SELECT mod(s_i_id * s_w_id, 10000) "
                    + "FROM " + CHBenCHmark.TABLE + ".stock "
                    + "INNER JOIN " + CHBenCHmark.TABLE + ".item ON i_id = s_i_id "
                    + "INNER JOIN " + CHBenCHmark.TABLE + ".order_line ON ol_i_id = s_i_id "
                    + "WHERE ol_delivery_d > '2010-05-23 12:00:00' "
                    + "AND i_data LIKE 'co%' "
                    + "GROUP BY s_i_id, "
                    + "s_w_id, "
                    + "mod(s_i_id * s_w_id, 10000), "
                    + "s_quantity HAVING 2*s_quantity > sum(ol_quantity)) "
                    + "AND su_nationkey = n_nationkey "
                    + "AND n_name = 'Germany' "
                    + "ORDER BY su_name"
    );

    protected SQLStmt get_query() {
        return query_stmt;
    }
}
