import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

import { APIResponse } from 'src/app/models/api-response';
import { serverPath } from 'src/app/common/global';
import { IndividualStatement } from 'src/app/models/individualstatements';

@Injectable({
  providedIn: 'root',
})
export class IndividualStatementsService {
  constructor(private http: HttpClient) {}

  individualstatementsServicePath = 'core/individualstatements/';

  getAllIndividualStatements(): Observable<APIResponse<Array<IndividualStatement>>> {
    const url = serverPath + this.individualstatementsServicePath;
    return this.http.get<APIResponse<Array<IndividualStatement>>>(url);
  }

  getIndividualStatement(individualstatement_id: number): Observable<APIResponse<Array<IndividualStatement>>> {
    const url = `${serverPath}${this.individualstatementsServicePath}${individualstatement_id}`;
    return this.http.get<APIResponse<Array<IndividualStatement>>>(url);
  }

  addIndividualStatement(individualstatement: IndividualStatement): Observable<APIResponse<IndividualStatement>> {
    const url = serverPath + this.individualstatementsServicePath;
    return this.http.post<APIResponse<IndividualStatement>>(url, individualstatement);
  }

  updateIndividualStatement(individualstatement: IndividualStatement, id: number): Observable<APIResponse<IndividualStatement>> {
    const url = `${serverPath}${this.individualstatementsServicePath}${id}`;
    return this.http.put<APIResponse<IndividualStatement>>(url, individualstatement);
  }

  deleteIndividualStatement(id: number): Observable<APIResponse<number>> {
    const url = `${serverPath}${this.individualstatementsServicePath}${id}`;
    return this.http.delete<APIResponse<number>>(url);
  }

}
